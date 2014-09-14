class window.Popup
  constructor:->
    @table_name ||= @_controller
    @action     ||= @_action
    @action       = 'new'  if @_action is 'form'
    @action       = 'edit' if @_action is 'form' and @$stateParams.id
    @$export 'save',
             'cancel',
             'bg_cancel'
    @$on "#{@table_name}/#{@action}#pop", @pop
    @$on 'popup/close'                  , @esc_cancel
    @$.submit = true
    @whitelist.push 'id' if @whitelist
    if @table_name
      name = _.singularize @table_name
      name = name.replace /_/, ' '
      @$.title = "#{_.capitalize(@action)} #{name}"
    @$.action = @action
  pop:(e,data={})=>
    @$root.$broadcast 'reset_popup_position'
    _.each data, (v,k)=> @$[k] = v unless k is 'model'
    @_register()
    switch @action
      when 'new'
        @$.model = data.model || @model || {}
        if @pull
          @Api[@table_name].new()
      when 'edit'
        if @pull
          @Api[@table_name].edit data.model
        else
          model = if @whitelist
            @$.model_prev = data.model
            data = _.pick data.model, @whitelist
          else
            angular.copy data.model
          @$.model = model
    @$.pop     = true
    @$root.popped = true
  bg_cancel:(e)=>
    if e && e.target && $(event.target).hasClass('popup_wrap')
      e.stopPropagation() if event.stopPropagation
      e.preventDefault()  if event.preventDefault
      e.cancelBubble = true
      e.returnValue  = false
      @$.pop = false
      @$.$apply() unless @$.$$phase
  esc_cancel:=>
    @$.pop = false
    @$root.popped = false
    @$.$apply() unless @$.$$phase
  cancel:=>
    @$.pop = false
    @$root.popped = false
  save:=>
    params      = @filter_params()
    opts        = @context()
    opts.prefix = @_prefix()  if _.any @scope
    switch @action
      when 'new'  then @Api[@table_name].create params, opts
      when 'edit' then @Api[@table_name].update @$.model.id, params, opts
      else @Api[@table_name][@action] @$.model.id, params, opts
  edit_success:(e,data)=>
    @$.model = data
  success:(e,data)=>
    @$.pop = false
    @$root.popped = false
  err:(e,data)=>
    @$.user.errors = data.errors
    @$.pop = true
  context:=> {}
  filter_params:()=>
    name    = _.singularize @table_name
    attrs   = _.omit @$.model, 'id'
    attrs   = _.pick @$.model, @whitelist if @whitelist
    @params = {}
    @params[name] = attrs
    @params
  _register:=>
    path = @table_name
    path = [@_prefix(),@table_name].join '/'  if _.any @scope
    switch @action
      when 'new'
        @$.$on "#{path}/create"    , @success
        @$.$on "#{path}/create#err", @err
      when 'edit'
        @$.$on "#{path}/update"    , @success
        @$.$on "#{path}/update#err", @err
        if @pull
          @$.$on "#{path}/edit"    , @edit_success
      else
        @$.$on "#{path}/#{@action}"    , @success
        @$.$on "#{path}/#{@action}#err", @err
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
