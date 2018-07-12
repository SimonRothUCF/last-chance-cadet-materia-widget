Matching = angular.module 'matching'

Matching.directive 'ngAudioControls', ->
	restrict: 'EA'
	scope:
		audioSource: '@audioSource'
	templateUrl: 'audioControls.html'
	controller: ['$scope', '$sce', ($scope, $sce) ->
		$scope.audio = null
		$scope.currentTime = 0
		$scope.duration = 0

		if typeof $scope.audioSource == "string"
			$scope.audio = new Audio()
			$scope.audio.src = $sce.trustAsResourceUrl($scope.audioSource)
		else
			throw 'Invalid source!'

		$scope.play = ->
			if $scope.audio.paused then $scope.audio.play()
			else $scope.audio.pause()

		$scope.toMinutes = (time) ->
			minutes = parseInt Math.floor(time / 60), 10
			seconds = parseInt Math.floor(time % 60), 10
			if seconds < 10 then seconds = '0' + seconds
			return '' + minutes + ':' + seconds

		$scope.changeTime = () ->
			$scope.audio.currentTime = $scope.currentTime

		# should only occur once, when the file is done loading
		$scope.audio.ondurationchange = () ->
			$scope.currentTime = 0
			$scope.duration = $scope.audio.duration
			$scope.$apply()

		$scope.audio.ontimeupdate = () ->
			$scope.currentTime = $scope.audio.currentTime
			$scope.$apply()
	]