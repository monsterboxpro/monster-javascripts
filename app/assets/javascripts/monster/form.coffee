class window.Form
  root: false
  omit: ['id', 'created_at', 'updated_at']
  constructor:->
    @table_name ||= @_controller
    @action     ||= @_action
    @action       = 'new'  if @_action is 'form'
    @action       = 'edit' if @_action is 'form' and @$stateParams.id
    @$.save = @save
    @_register()
    @reset()
  reset:=>
    switch @action
      when 'new'
        @$.model = angular.copy(@model) || {}
      when 'edit'
        @Api[@table_name].edit @$stateParams.id, @reset_params(), @attrs()
  reset_params:=> {}
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
        @$on "#{@table_name}/create"    , @create_success
        @$on "#{@table_name}/create#err", @create_failure
  filter_params:=>
    name    = _.singularize @table_name
    attrs   = _.omit @$.model, @omit
    @params = {}
    @params[name] = attrs
    @params
  edit_success:(e,data)=>
    @$.model     = data
    name         = _.singularize @table_name
    @$root[name] = data if @root
  create_success:=> @success()
  update_success:=>  @success()
  success:=>  @$state.go "#{@table_name}.show", {id: @$.model.id}
  create_failure:(e,data)=>
    @$.error_set_focus = false
    @$.errors = data
  attrs:=>
    {}
