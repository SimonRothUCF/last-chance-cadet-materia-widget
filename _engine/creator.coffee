###

Materia
It's a thing

Widget  : Hangman, Creator
Authors : Brandon Stull, Micheal Parks
Updated : 11/13

###

# Create an angular module to import the animation module and house our controller.
HangmanCreator = angular.module 'HangmanCreator', ['ngAnimate', 'ngSanitize']

HangmanCreator.factory 'Resource', ['$sanitize', ($sanitize) ->
	buildQset: (title, items, partial, attempts) ->
		qsetItems = []
		qset = {}

		# Decide if it is ok to save.
		if title is ''
			Materia.CreatorCore.cancelSave 'Please enter a title.'
			return false
		else
			for i in [0..items.length-1]
				if items[i].ans.length > 34
					Materia.CreatorCore.cancelSave 'Please reduce the number of characters in word #'+(i+1)+'.'
					return false

		qset.options = {partial: partial, attempts: attempts}
		qset.assets = []
		qset.rand = false
		qset.name = title

		qsetItems.push @processQsetItem items[i] for i in [0..items.length-1]
		qset.items = [{items: qsetItems}]

		qset

	processQsetItem: (item) ->
		item.ques = $sanitize item.ques
		item.ans = item.ans

		qsetItem = {}
		qsetItem.assets = []

		qsetItem.materiaType = "question"
		qsetItem.id = ""
		qsetItem.type = 'QA'
		qsetItem.questions = [{text : item.ques}]
		qsetItem.answers = [{value : '100', text : item.ans}]

		qsetItem

	placeholderPolyfill: () ->
		$('[placeholder]')
		.focus ->
			if this.value is this.placeholder
				this.value = ''
				this.className = ''
		.blur ->
			if this.value is '' or this.value is this.placeholder
				this.className = 'placeholder'
				this.value = this.placeholder

		$('form').submit ->
			$(this).find('[placeholder]').each ->
				if this.value is this.placeholder then this.value = ''

]

# Set the controller for the scope of the document body.
HangmanCreator.controller 'HangmanCreatorCtrl', ['$scope', ($scope) ->
	$scope.title = ""
	$scope.items = []
	$scope.partial = false
	$scope.attempts = 5

	$scope.addItem = (ques = "", ans = "") ->
		$scope.items.push {ques:ques, ans:ans, foc:false}

	$scope.removeItem = (index) ->
		$scope.items.splice index, 1

	$scope.initNewWidget = (widget, baseUrl) ->
		$scope.addItem()

		if not Modernizr.input.placeholder then Resource.placeholderPolyfill()

	$scope.initExistingWidget = (title, widget, qset, version, baseUrl) ->
		$scope.title = title
		$scope.attempts = qset.options.attempts
		$scope.partial = qset.options.partial
		onQuestionImportComplete qset.items[0].items

		if not Modernizr.input.placeholder then Resource.placeholderPolyfill()

	$scope.onSaveClicked = (mode = 'save') ->
		qset = Resource.buildQset $sanitize $scope.title, $scope.items, $scope.partial, $scope.attempts
		if qset then Materia.CreatorCore.save _title, _qset 

	$scope.onSaveComplete = (title, widget, qset, version) -> true

	$scope.onQuestionImportComplete = (items) ->
		$scope.addItem items[i].questions[0].text, items[i].answers[0].text for i in [0..items.length-1]

	$scope.onMediaImportComplete = (media) -> true
]

# Load Materia Dependencies and start.
do () -> require ['creatorcore'], (util) ->
	Materia.CreatorCore.start angular.element($('body')).scope()