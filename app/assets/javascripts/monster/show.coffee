class window.Show
  scope: []
  pull   : false
  popups : false
  action : 'show'
  collection_name: null
  attrs: => {}
  constructor:->
    @table_name = @_controller unless @table_name
    @_register()
    @reindex() if @pull
    if @popups is true
      name = @collection_name || @table_name
      @$.pop =
        edit: if @Event[name] && @Event[name].edit then @Event[name].edit else @Event.template(name,'edit')
    @$.destroy = @destroy
  _register:=>
    path = @table_name
    path = [@_prefix(),name].join '/'  if _.any @scope
    @$on "#{path}/show"   , @show_success
    @$on "#{path}/update" , @update_success
    @$on "#{path}/destroy", @destroy_success
  show_success:(e,data)=>
    @$.model = data
  update_success:(e,data)=>
    @$.model = data
  reindex:=>
    attrs = @attrs()
    @Api[@table_name][@action] {id: @$stateParams.id}, attrs
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
  destroy:(model)=>
    name = _.singularize @table_name
    msg  = "Are you sure you wish to destroy this #{name}"
    @Api[@table_name].destroy model, @attrs() if confirm msg
