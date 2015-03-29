angular.module "geoPusher"
  .controller "TutorialCtrl", ($scope, $mdDialog) ->

    $scope.showPreview = (imageURL) ->
      parentEl = angular.element(document.body)
      $mdDialog.show
        template: """<md-dialog aria-label="List dialog">
           <md-content>
             <img src="#{imageURL}">
           </md-content>
         </md-dialog>
        """
