angular.module "geoPusher", ['ngAnimate', 'ngCookies', 'ngTouch', 'ngSanitize', 'ngResource', 'ui.router', 'ngMaterial', 'pusher-angular']
  .config ($stateProvider, $urlRouterProvider) ->
    $stateProvider
      .state "home",
        url: "/",
        templateUrl: "app/main/main.html",
        controller: "MainCtrl"
      .state "tutorial",
        url: "/tutorial",
        templateUrl: "app/tutorial/tutorial.html",
        controller: "TutorialCtrl"

    $urlRouterProvider.otherwise '/'

