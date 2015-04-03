angular.module("geoPusher").controller("MainCtrl", function($scope, $mdDialog, $pusher) {

  $scope.message = {};

  $scope.state = {
    pusherSubscription: {
      active: false
    }
  };

  var client = new Pusher("{{ PUSHER_APP_KEY }}", {
    authEndpoint: "{{ HOST_NAME }}/pusher/auth"
  });

  var pusher = $pusher(client);

  var mapOptions = {
    zoom: 14,
    center: {
      lat: 51.536208,
      lng: -0.07873
    }
  };

  var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);

  var alert = $mdDialog.alert({
    title: 'Getting your location',
    content: 'You may need to allow GeoLocation. Hit accept at the top of your screen.'
  });

  $scope.subscribeToLocalRoom = function() {
    $scope.channel = pusher.subscribe("private-location-" + ($scope.roomName()));

    $scope.channel.bind("pusher:subscription_succeeded", function() {
      $scope.state.pusherSubscription.active = true;
    });

    $scope.channel.bind("client-message-event", $scope.onMessage);
  };

  $scope.getPositionToDegreeOfAccuracy = function(accuracy) {
    return {
      latitude: $scope.position.coords.latitude.toFixed(accuracy),
      longitude: $scope.position.coords.longitude.toFixed(accuracy)
    };
  };

  $scope.roomName = function() {
    var position = $scope.getPositionToDegreeOfAccuracy(1);
    return "" + position.latitude + position.longitude;
  };

  $scope.shouldShowNewMessageForm = function() {
    return $scope.state.pusherSubscription.active
  };

  $scope.post = function() {
    $scope.channel.trigger("client-message-event", {
      message: $scope.message.body,
      position: $scope.getPositionToDegreeOfAccuracy()
    });
  };

  $scope.onMessage = function(data) {
    var position = new google.maps.LatLng(data.position.latitude, data.position.longitude);

    new google.maps.InfoWindow({
      map: map,
      position: position,
      content: data.message
    });
  };

  $mdDialog.show(alert);

  navigator.geolocation.getCurrentPosition(function(position) {
    $scope.position = position;
    latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
    map.setCenter(latLng);
    $mdDialog.hide();

    $scope.subscribeToLocalRoom()
  });
});
