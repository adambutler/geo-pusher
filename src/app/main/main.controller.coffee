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

    $scope.channel = pusher.subscribe('private-channel')

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

    $scope.post = ->
      $scope.onMessage($scope.message.body, $scope.position)

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
        pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
        map.setCenter pos
        map.setZoom 12
