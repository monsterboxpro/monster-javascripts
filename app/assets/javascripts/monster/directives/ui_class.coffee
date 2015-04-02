Link = ($state, $stateParams, $interpolate) ->
  restrict: 'A'
  controller: ['$scope','$element','$attrs',($scope, $element, $attrs) ->
    update = ->
      if $state.current.templateUrl
        class_name = $state.current.templateUrl.replace /\//g, '_'
        $element.attr 'location', class_name
      return
    @$$setStateInfo = (newState, newParams) ->
      state  = $state.get(newState, stateContext($element))
      params = newParams
      update()
      return
    $scope.$on '$stateChangeSuccess', update
  ]
app.directive 'uiClass',['$state', '$stateParams','$interpolate',Link]
