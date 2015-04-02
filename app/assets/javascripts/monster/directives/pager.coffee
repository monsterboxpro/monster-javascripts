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
    <div class='pager'>
      <div class="button prev" ng-click="previous_page()" ng-class="{enabled: has_previous_page()}">
        <span class="fa fa-chevron-left"></span>
      </div>
      <div class="button next" ng-click="next_page()" ng-class="{enabled: has_next_page()}">
        <span class="fa fa-chevron-right"></span>
      </div>
      <div class='clear'></div>
    </div>
  '''
app.directive 'pager', [directive]
