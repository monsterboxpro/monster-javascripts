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
