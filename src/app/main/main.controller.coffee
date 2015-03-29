angular.module "geoPusher"
  .controller "MainCtrl", ($scope, $mdDialog, $pusher) ->
    $scope.message = {}
    $scope.state = {
      pusherSubscription: {
        active: false
      }
    }

    # Do not change PUSHER_APP_KEY this will be injected
    # automagically from the .env file
    client = new Pusher "PUSHER_APP_KEY", {
      authEndpoint: "HOST_NAME/pusher/auth"
    }

    pusher = $pusher(client)

    $scope.subscribeToLocalRoom = ->
      $scope.channel = pusher.subscribe("private-location-#{$scope.roomName()}")

      $scope.channel.bind "pusher:subscription_succeeded", ->
        $scope.state.pusherSubscription.active = true

      $scope.channel.bind "client-message-event", $scope.onMessage

    alert = $mdDialog.alert({
      title: 'Getting your location',
      content: 'You may need to allow GeoLocation. Hit accept at the top of your screen.'
    })

    mapOptions =
      zoom: 14
      center:
        lat: 51.536208,
        lng: -0.07873

    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)

    $scope.getPositionToDegreeOfAccuracy = (accuracy = 2) ->
      {
        latitude: $scope.position.coords.latitude.toFixed(accuracy)
        longitude: $scope.position.coords.longitude.toFixed(accuracy)
      }

    $scope.roomName = ->
      position = $scope.getPositionToDegreeOfAccuracy(1)
      "#{position.latitude}#{position.longitude}"

    $scope.shouldShowNewMessageForm = ->
      return false unless $scope.position?
      return false unless $scope.state.pusherSubscription.active
      return true

    $scope.post = ->
      $scope.channel.trigger("client-message-event",
        message: $scope.message.body,
        position: $scope.getPositionToDegreeOfAccuracy()
      )

    $scope.onMessage = (data) ->
      console.log data
      position = new google.maps.LatLng(data.position.latitude, data.position.longitude)
      infowindow = new google.maps.InfoWindow(
        map: map
        position: position
        content: data.message
      )

    if navigator.geolocation
      $mdDialog.show(alert)
      navigator.geolocation.getCurrentPosition (position) ->
        $scope.position = position
        $mdDialog.hide()
        $scope.subscribeToLocalRoom()

        pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
        map.setCenter pos
