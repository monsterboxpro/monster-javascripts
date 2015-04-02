$controller 'monster-directives/monster_nested_list', '$attrs', class
  constructor:->
    @$export 'remove_item',
             'add_item'
  remove_item:(model)=>
    val = @$attrs.monsterNestedlist
    i = @$.model[val].indexOf model
    if model.id
      key = 'remove_'+val.replace(/attrs/,'ids')
      @$.model[key] ||= []
      @$.model[key].push model.id
    @$.model[val].splice i, 1
  add_item:=>
    val = @$attrs.monsterNestedlist
    @$.model[val] ||= []
    @$.model[val].push {}

$directive 'monsterNestedlist', ->
  controller: 'monster-directives/monster_nested_list'
