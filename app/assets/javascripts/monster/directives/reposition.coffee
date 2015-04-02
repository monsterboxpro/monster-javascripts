$controller 'monster-directives/reposition', '$attrs', '$element',  class
  constructor:->
    @el = @$attrs.repositionEl || '.picture_item'
    opts =
      start       : @start
      update      : @update
      handle      : (@$attrs.repositionHandle || '.handle .fa-bars')
      items       : (@el)
    @$element.sortable opts
  start:(e, ui)=> 
    @before = @map()
  update:(e, ui)=>
    @after = @map()
    @remove_extra()
    @reindex()
  remove_extra:=>
    val     = _.difference @before, @after
    index   = @before.indexOf val[0]
    @before.splice index, 1
  map:=>
    _.map @$element.find(@el), (item)=>
      angular.element(item).scope().$id
  reindex:=>
    reposition = @after
    for i in [0..@after.length-1]
     aindex = @after.indexOf @before[i]
     reposition[aindex] = @$.reposition[i]
    @$.reposition = reposition
    @$.$apply()

$directive 'repositionItems', ->
  controller: 'monster-directives/reposition'
  scope:
    reposition: '=repositionItems'
