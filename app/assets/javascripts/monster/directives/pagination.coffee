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
