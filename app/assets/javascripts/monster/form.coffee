class window.Form
  root: false
  pull: false
  omit: ['id', 'created_at', 'updated_at']
  constructor:->
    @table_name ||= @_controller
    @action     ||= @_action
    @action       = 'new'  if @_action is 'form'
    @action       = 'edit' if @_action is 'form' and @$stateParams.id
    @$.save  = @save
    @$.back  = @back
    @$.title = "#{@action} #{@table_name}"
    @_register()
    @reset()
  reset:=>
    switch @action
      when 'new'
        @$.model = angular.copy(@model) || {}
        @Api[@table_name].new @attrs() if @can_pull('new')
      when 'edit'
        @Api[@table_name].edit @$stateParams.id, @attrs() if @can_pull('edit')
  context:=> {}
  save:=>
    params      = @filter_params()
    opts        = @context()
    opts.prefix = @_prefix()  if _.any @scope
    switch @action
      when 'new'  then @Api[@table_name].create             params, opts
      when 'edit' then @Api[@table_name].update   @$.model, params, opts
      else             @Api[@table_name][@action] @$.model, params, opts
  _register:=>
    switch @action
      when 'edit'
        @$on "#{@table_name}/edit"      , @edit_success
        @$on "#{@table_name}/update"    , @update_success
        @$on "#{@table_name}/update#err", @create_failure
      when 'new'
        @$on "#{@table_name}/new"       , @new_success
        @$on "#{@table_name}/create"    , @create_success
        @$on "#{@table_name}/create#err", @create_failure
  filter_params:=>
    name    = _.singularize @table_name
    attrs   = _.omit @$.model, @omit
    @params = {}
    @params[name] = attrs
    @params
  new_success:(e,data)=>
    @$.model     = data
    name         = _.singularize @table_name
    @$root[name] = data if @root
  edit_success:(e,data)=>
    @$.model     = data
    name         = _.singularize @table_name
    @$root[name] = data if @root
  create_success:(e,data)=> @success data
  update_success:(e,data)=>  @success data
  success:(data)=> @$state.go "#{@table_name}.show", {id: data.id}
  create_failure:(e,data)=>
    @$.error_set_focus = false
    @$.errors = data
  attrs:=>
    {}
  can_pull:(name)=>
    if _.isArray @pull
      _.any @pull, (n)-> n is name
    else
      @pull
  back:=>
    switch @action
      when 'new'  then @$state.go @table_name
      when 'edit' then @$state.go "#{@table_name}.show"
