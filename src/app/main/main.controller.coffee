angular.module "geoPusher"
  .controller "MainCtrl", ($scope, $mdDialog, $pusher) ->
    $scope.message = {}
    $scope.state = {
      pusherSubscription: {
        active: false
      }
    }

    client = new Pusher "YOUR_APP_KEY", {
      authEndpoint: "http://127.0.0.1:5000/pusher/auth"
    }

    pusher = $pusher(client)

    $scope.subscribeToLocalRoom = ->
      $scope.channel = pusher.subscribe("private-location-#{$scope.roomName()}")

      $scope.channel.bind "pusher:subscription_succeeded", ->
        $scope.state.pusherSubscription.active = true

    alert = $mdDialog.alert({
      title: 'Getting your location',
      content: 'You may need to allow GeoLocation. Hit accept at the top of your screen.'
    })

    mapOptions =
      zoom: 8
      center:
        lat: -34.397
        lng: 150.644

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

    $scope.onMessage = (message, position) ->
      pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      infowindow = new google.maps.InfoWindow(
        map: map
        position: pos
        content: message
      )

    if navigator.geolocation
      $mdDialog.show(alert)
      navigator.geolocation.getCurrentPosition (position) ->
        $scope.position = position
        $mdDialog.hide()
        $scope.subscribeToLocalRoom()

        pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
        map.setCenter pos
        map.setZoom 14
