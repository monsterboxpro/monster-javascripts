app.directive 'draggablePopup', ->
  (scope,element,attrs)->
    element.draggable
      handle: '.popup_heading'
    scope.$on 'reset_popup_position', ->
      element.removeAttr 'style'

#app.directive 'esc', ->
  #(scope, element, attrs) ->
    #$(document).bind 'keydown', 'esc', ()=>
      #scope.$root.$broadcast 'popup/close'
    #$('input,textarea,select').bind 'keydown', 'esc', ()=>
      #scope.$root.$broadcast 'popup/close'

app.directive 'focusOn', ->
  link: (scope,element,attrs) ->
    scope.$watch attrs.focusOn, ->
      if scope.$eval(attrs.focusOn) == true
        _.defer ->
          element.focus()
      else if element.is(':focus')
        _.defer ->
          element.blur()

app.directive 'ready', ->
  (scope, element, attrs) ->
    element.removeClass 'not_ready'

directive = ($state, $stateParams, $interpolate) ->
  restrict: 'A'
  controller: ['$scope','$element','$attrs',($scope, $element, $attrs) ->
      equalForKeys = (a, b, keys) ->
        unless keys
          keys = []
          for n of a # Used instead of Object.keys() for IE8 compatibility
            continue
        i = 0

        while i < keys.length
          k = keys[i]
          return false  unless a[k] is b[k] # Not '===', values aren't necessarily normalized
          i++
        true
      matchesParams = ->
        not params or equalForKeys(params, $stateParams)
      update = ->
        actives      = $attrs.uiActive.split ' '
        active_class = false
        for active in actives
          if $state.current.controller.match active
            active_class = true

        if active_class
          $element.addClass 'active'
        else
          $element.removeClass 'active'
        return
      @$$setStateInfo = (newState, newParams) ->
        state  = $state.get(newState, stateContext($element))
        params = newParams
        update()
        return
      $scope.$on '$stateChangeSuccess', update
  ]
app.directive 'uiActive', ['$state', '$stateParams', '$interpolate',directive]

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


controller = class
  constructor:(@$)->
    @$.has_next_page = @has_next_page
    @$.has_previous_page = @has_previous_page
    @$.next_page = @next_page
    @$.previous_page = @previous_page
  next_page:=>
    return unless @has_next_page()
    @$.$parent.pagination.page++
  previous_page:=>
    return unless @has_previous_page()
    @$.$parent.pagination.page--
  has_next_page:=> !@$.$parent.pagination?.last_page
  has_previous_page:=> !@$.$parent.pagination?.first_page
directive = () ->
  priority: 1000
  controller: ['$scope', controller]
  scope: {}
  template: '''
    <div class="button" ng-click="previous_page()">
      <span class="fa fa-chevron-left"></span>
    </div>
    <div class="button" ng-click="next_page()">
      <span class="fa fa-chevron-right"></span>
    </div>
  '''
app.directive 'pagination', [directive]

$directive 'tableHeading', '$timeout','$window',
  ($timeout,$window)->
    (scope,element,attrs)->
      resize = ->
        fun = ->
          parent  = element.parent('.data-table')
          columns = parent.find('.model:first .cell')
          _.each columns, (e,i)=>
            width = angular.element(e).outerWidth()
            element.find(".cell:nth-child(#{i+1})").css width: "#{width}px"
        $timeout fun, 0
      angular.element($window).bind 'resize', resize
      scope.$watch attrs.tableHeading       , resize
      scope.$on 'data_heading'              , resize
