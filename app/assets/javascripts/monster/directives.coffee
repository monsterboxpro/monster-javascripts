app.directive 'draggablePopup', ->
  (scope,element,attrs)->
    element.draggable
      handle: '.popup_heading'
    scope.$on 'reset_popup_position', ->
      element.removeAttr 'style'

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

$directive 'uiActive', '$state',
  ($state)->
    (scope,element,attrs)->
      update = ->
        if $state.current.templateUrl
          name =
          if attrs.uiBy and attrs.uiBy is 'name'
            $state.current.name
          else
            $state.current.templateUrl.replace /\//g, '_'
          reg = new RegExp attrs.uiActive
          if name.match(reg)
            element.addClass 'active'
          else
            element.removeClass 'active'
        return
      @$$setStateInfo = (newState) ->
        state = $state.get newState, stateContext(element)
        update()
        return
      scope.$on '$stateChangeSuccess', update

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


$controller 'monster-directives/pagination', class
  constructor:->
    @$.has_next_page     = @has_next_page
    @$.has_previous_page = @has_previous_page
    @$.next_page         = @next_page
    @$.previous_page     = @previous_page
  next_page:=>
    return unless @has_next_page()
    @$.$parent.pagination.page++
  previous_page:=>
    return unless @has_previous_page()
    @$.$parent.pagination.page--
  has_next_page:=>     !@$.$parent.pagination?.last_page
  has_previous_page:=> !@$.$parent.pagination?.first_page
directive = () ->
  priority: 1000
  controller: 'monster-directives/pagination'
  scope: {}
  template: '''
    <div class="button prev" ng-click="previous_page()">
      <span class="fa fa-chevron-left"></span>
    </div>
    <div class="button next" ng-click="next_page()">
      <span class="fa fa-chevron-right"></span>
    </div>
  '''
app.directive 'pager', [directive]

$directive 'tableHeading', '$timeout','$window',
  ($timeout,$window)->
    (scope,element,attrs)->
      scroll = ->
        fun = ->
          parent      = element.parent('.data-table')
          left        = parent.find('.model:first').offset().left
          scroll_left = angular.element($window).scrollLeft()
          parent.find('.item.heading').css left: left-scroll_left
        $timeout fun, 0
      resize = ->
        fun = ->
          parent  = element.parent('.data-table')
          w = parent.find('.model:first').outerWidth()
          parent.find('.item.heading').width w
          columns = parent.find('.model:first .cell')
          _.each columns, (e,i)=>
            width = angular.element(e).outerWidth()
            element.find(".cell:nth-child(#{i+1})").css width: "#{width}px"
        $timeout fun, 0
      angular.element($window).bind 'resize', resize
      #angular.element($window).bind 'scroll', scroll
      scope.$watch attrs.tableHeading       , resize
      scope.$on 'data_heading'              , resize

$directive 'bgImage', ->
  scope:
    "bg_image": "=bgImage"
  link: (scope,element,attrs)->
    element.css 'background-image', "url(#{scope.bg_image})"

$controller 'monster-directives/pagination-full', class
  constructor:->
    @$.has_next_page     = @has_next_page
    @$.has_previous_page = @has_previous_page
    @$.next_page         = @next_page
    @$.previous_page     = @previous_page
    @$watch 'pagination.page', @update_pages
    @$watch 'pagination.total_pages', @update_pages
    @$export 'go_to_page'
  go_to_page:(page)=>
    @$.pagination.page = page
  next_page:=>
    return unless @has_next_page()
    @$.pagination.page++
  previous_page:=>
    return unless @has_previous_page()
    @$.pagination.page--
  update_pages:(oldv,newv)=>
    return unless oldv != newv
    if @$.pagination
      if @$.pagination.total_pages == 0
        @$.pages = []
      else
        numbers = []
        range = [(@$.pagination.page - 2)..(@$.pagination.page + 2)]
        numbers = (n: n, type: 'page' for n in range)
        while numbers[0].n < 1
          numbers.shift()
        while _.last(numbers).n > @$.pagination.total_pages
          numbers.pop()
        _.findWhere(numbers,n: @$.pagination.page).type = 'current_page'
        numbers.unshift type: 'skip'                              if numbers[0].n >= 3
        numbers.unshift type: 'page', n: 1                         if numbers[0].n != 1
        numbers.push    type: 'skip'                               if _.last(numbers).n < @$.pagination.total_pages - 1
        numbers.push    type: 'page', n: @$.pagination.total_pages if _.last(numbers).n != @$.pagination.total_pages
        @$.pages = numbers
    numbers
  has_next_page:=>     !@$.pagination?.last_page
  has_previous_page:=> !@$.pagination?.first_page


$directive 'monsterPaginateFull', '$templateCache', '$compile', ($templateCache,$compile) ->
  scope:
    'pagination': '=monsterPaginateFull'
  controller: 'monster-directives/pagination-full'
  link:(scope,element,attrs)->
    if attrs.monsterTemplate
      html = $templateCache.get(attrs.monsterTemplate)
    else
      html = """
        <div class="monster_paginate">
          <span class="button" ng-click="previous_page()">
            Previous
          </span>
          <span class="page_number" ng-repeat="page in pages" ng-click="go_to_page(number)">
            <span ng-switch="page.type">
              <span ng-switch-when="page">
                <a href="#" ng-click="go_to_page(page.n)">{{page.n}}</a>
              </span>
              <span ng-switch-when="current_page">
                <strong>{{page.n}}</strong>
              </span>
              <span ng-switch-when="skip">
                &hellip;
              </span>
            </span>
          </span>
          <span class="button" ng-click="next_page()">
            Next
          </span>
        </div>
      """
    template = $compile(html)(scope)
    element.html template


$directive 'monsterFile', ->
  scope:
    model: '=monsterFile'
  link:(scope,element,attrs)->
    element.on 'change', (e)->
      scope.model = e.target.files[0]
      scope.$apply()


$controller 'monster-directives/autocomplete', '$attrs',  class
  constructor:->
    c = null
    a = null
    [c,a] = @$attrs.monsterRequest.split('.')
    @$on "#{c}/#{a}", @success
    @$export 'select',
             'reindex'
  select:(model)=>
    @$.search = model.name
    @$.model_id  = model.id
    @$.results = null
  reindex:=>
    return unless @$attrs.monsterRequest
    c = null
    a = null
    [c,a] = @$attrs.monsterRequest.split('.')
    if @$.search && @$.search.length != 0
      @Api[c][a] search: @$.search
    else
      @$.results = null
  success:(e,data)=>
    @$.results = data
$directive 'monsterAutocomplete', '$templateCache', '$compile', ($templateCache,$compile) ->
  scope:
    model_id:   '=monsterAutocomplete'
    search:      '=monsterValue'
  controller: 'monster-directives/autocomplete'
  link:(scope,element,attrs)->
    if attrs.monsterTemplate
      html = $templateCache.get(attrs.monsterTemplate)
    else
      html = """
  <div class='monster-autocomplete'>
    <div class='fa fa-search'></div>
    <input type='text' ng-model='search' ng-debounce='500' ng-change='reindex()' />
    <div class='results' ng-show='results'>
      <div class='result' ng-click='select(result)' ng-repeat='result in results'>
        <span ng-bind-html='result.name | highlight:search'></span>
      </div>
    </div>
  </div>
      """
    template = $compile(html)(scope)
    element.html template
