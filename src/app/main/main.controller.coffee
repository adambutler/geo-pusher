angular.module "geoPusher"
  .controller "MainCtrl", ($scope, $mdDialog) ->

    mapOptions =
      zoom: 8
      center:
        lat: -34.397
        lng: 150.644

    map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
