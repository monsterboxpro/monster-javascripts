class window.List
  scope: []
  pull   : false
  popups : false
  root   : false
  action : 'index'
  constructor:->
    @table_name = @_controller unless @table_name
    @_register()
    if @popups is true
      @$.pop =
        new:  if @Event[@table_name] then @Event[@table_name].new  else @Event.template(@table_name,'new')
        edit: if @Event[@table_name] then @Event[@table_name].edit else @Event.template(@table_name,'edit')
    @Api[@table_name][@action]() if @pull
    @index_success null, @data() if @data
    @$.destroy = @destroy
  destroy:(model,e)=>
    e.stopPropagation() if e.stopPropagation
    e.preventDefault()  if e.preventDefault
    e.cancelBubble = true
    e.returnValue  = false

    name = _.singularize @table_name
    msg  = "Are you sure you wish to to destroy this #{name}"
    @Api[@table_name].destroy model if confirm msg
  index_success:(e,data)=>
    if @root
      @$.$root[@table_name] = data
    else
      @$[@table_name] = data
    @collection          = @$[@table_name]
  create_success:(e,data)=>  _.create  @collection, data
  update_success:(e,data)=>  _.update  @collection, data
  destroy_success:(e,data)=> _.destroy @collection, data
  _register:=>
    path = @table_name
    path = [@_prefix(),@table_name].join '/'  if _.any @scope
    @_events = []
    @_events.push @$on "#{path}/#{@action}", @index_success
    @_events.push @$on "#{path}/create" , @create_success
    @_events.push @$on "#{path}/update" , @update_success
    @_events.push @$on "#{path}/destroy", @destroy_success
    @$on '$destroy', @_unregister
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
  _unregister:=>
    for fn in @_events
      fn()

class window.PusherList
  scope: []
  pull: false
  popups: true
  root   : false
  action : 'index'
  constructor:->
    @table_name = @_controller unless @table_name
    @_register()
    if @popups is true
      @$.pop =
        new:  if @Event[@table_name] then @Event[@table_name].new  else @Event.template(@table_name,'new')
        edit: if @Event[@table_name] then @Event[@table_name].edit else @Event.template(@table_name,'edit')
    @Api[@table_name][@action]() if @pull
    @index_success null, @data() if @data
    @$.destroy = @destroy
  destroy:(model)=>
    name = _.singularize @table_name
    msg  = "Are you sure you wish to to destroy this #{name}"
    @Api[@table_name].destroy model if confirm msg
  index_success:(e,data)=>
    if @root is true
      @$root[@table_name] = data
    else
      @$[@table_name] = data
    @collection          = @$[@table_name]
  create_success:(data)=> 
    _.create  @collection, data
    @$.$apply()
  update_success:(data)=> 
    _.update  @collection, data
    @$.$apply()
  destroy_success:(data)=> 
    _.destroy @collection, data
    @$.$apply()
  _register:=>
    path = @table_name
    path = [@_prefix(),@table_name].join '/'  if _.any @scope
    project_id = @$stateParams.project_id
    @_events = []
    @_events.push @$on "#{path}/#{@action}", @index_success
    if project_id
      key = "private-projects.#{project_id}"
      @Pusher.subscribe key
      @Pusher.$on key, "#{path}/create" , @create_success
      @Pusher.$on key, "#{path}/update" , @update_success
      @Pusher.$on key, "#{path}/destroy", @destroy_success
    @$on '$destroy', @_unregister
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
  _unregister:=>
    for fn in @_events
      fn()
    project_id = @$stateParams.project_id
    if project_id
      path = @table_name
      path = [@_prefix(),@table_name].join '/'  if _.any @scope
      key = "private-projects.#{project_id}"
      @Pusher.$off key, "#{path}/create" , @create_success
      @Pusher.$off key, "#{path}/update" , @update_success
      @Pusher.$off key, "#{path}/destroy", @destroy_success
