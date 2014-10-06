class window.Popup
  ui_router: false
  pull: false
  constructor:->
    @table_name ||= @_controller
    @action     ||= @_action
    @$export 'save',
             'cancel',
             'bg_cancel'

    @_events = []
    if @_action is 'form'
      @_events.push @$on "#{@table_name}/new#pop" , @pop
      @_events.push @$on "#{@table_name}/edit#pop", @pop
      @_events.push @$on "#{@table_name}/form#pop", @pop
    else
      @_events.push @$on "#{@table_name}/#{@action}#pop", @pop
    @_events.push @$on 'popup/close', @esc_cancel
    if @_action is 'form' && @ui_router
      @action = 'new'
      @action = 'edit' if @$stateParams.id

    @$.submit = true
    @whitelist.push 'id' if @whitelist
  pop:(e,data={})=>
    @$root.$broadcast 'reset_popup_position'
    _.each data, (v,k)=> @$[k] = v unless k is 'model'

    if @_action is 'form' && @ui_router != true
      @action = 'new'
      @action = 'edit' if data.model && data.model.id
    @popup_title()
    @$.action = @action

    @_register()
    switch @action
      when 'new'
        @$.model = data.model || @model || {}
        @Api[@table_name].new() if @can_pull('new')
      when 'edit'
        if @can_pull('edit')
          @Api[@table_name].edit data.model, @attrs()
        else
          model = if @whitelist
            @$.model_prev = data.model
            data = _.pick data.model, @whitelist
          else
            angular.copy data.model
          @$.model = model
    @$.pop        = true
    @$root.popped = true
  attrs:=>
    {}
  can_pull:(name)=>
    if _.isArray @pull
      _.any @pull, (n)-> n is name
    else
      @pull
  popup_title:=>
    if @table_name
      name = _.singularize @table_name
      name = name.replace /_/, ' '
      @$.title = "#{_.capitalize(@action)} #{name}"
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
        @_events.push @$on "#{path}/create"    , @success
        @_events.push @$on "#{path}/create#err", @err
      when 'edit'
        @_events.push @$on "#{path}/update"    , @success
        @_events.push @$on "#{path}/update#err", @err
        @_events.push @$on "#{path}/edit"      , @edit_success if @can_pull('edit')
      else
        @_events.push @$on "#{path}/#{@action}"    , @success
        @_events.push @$on "#{path}/#{@action}#err", @err
    @$on '$destroy', @_unregister
  _unregister:=>
    for fn in @_events
      fn()
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
