# $controller 'users/show', class extends Popup
#   pull: true
#
# $controller 'users/form', class extends Popup
#   pull: ['edit']
#
# $controller 'users/show', class extends Popup
#   attrs:=>
#     { student_id: @$stateParams.id }
#
# $controller 'users/form', class extends Popup
#   title:
#     new: 'Add a user'
#     edit: 'Update a user'

# $controller 'users/form', class extends Popup
#   save_label:
#     new: 'Add'
#     edit: 'Update User'
#
class window.Popup
  ui_router: false
  pull: false
  constructor:->
    @table_name ||= @_controller
    @action     ||= @_action
    @$export 'save',
             'cancel',
             'bg_cancel',
             'destroy'
    if @_action is 'form'
      @$on "#{@table_name}/new#pop" , @pop
      @$on "#{@table_name}/edit#pop", @pop
      @$on "#{@table_name}/form#pop", @pop
    else
      @$on "#{@table_name}/#{@action}#pop", @pop
    @$on 'popup/close', @esc_cancel
    if @_action is 'form' && @ui_router
      @action = 'new'
      @action = 'edit' if @$stateParams.id

    @$.submit = true
    @whitelist.push 'id' if @whitelist
  pop:(e,data={})=>
    @$.errors = null
    @$root.$broadcast 'reset_popup_position'
    _.each data, (v,k)=> @$[k] = v unless k is 'model'

    if @_action is 'form' && @ui_router != true
      @action = 'new'
      @action = 'edit' if data.model && data.model.id
    @popup_title()
    @compute_save_label()
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
      else
        @$.model = angular.copy(data.model) || @model || {}
        @Api[@table_name][@action] data.model, @attrs() if @can_pull(@action)
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
    @$.title =
    if @title && @title.new && @action is 'new'
      @title.new
    else if @title && @title.edit && @action is 'edit'
      @title.edit
    else if @title
      @title
    else
      if @table_name
        name = _.singularize @table_name
        name = name.replace /_/, ' '
        @$.title = "#{_.capitalize(@action)} #{name}"
  compute_save_label:=>
    @$.save_label =
    if @save_label && @save_label.new  && @action is 'new'
      @save_label.new
    else if @save_label && @save_label.edit && @action is 'edit'
      @save_label.edit
    else if @save_label
      @save_label
    else
      'Save'
  bg_cancel:(e)=>
    if e && e.target && $(event.target).hasClass('popup_wrap')
      e.stopPropagation() if event.stopPropagation
      e.preventDefault()  if event.preventDefault
      e.cancelBubble = true
      e.returnValue  = false
      @$.errors = null
      @$.pop = false
      @$.$apply() unless @$.$$phase
  esc_cancel:=>
    @$.errors = null
    @$.pop = false
    @$root.popped = false
    @$.$apply() unless @$.$$phase
  cancel:=>
    @$.errors = null
    @$.pop = false
    @$root.popped = false
  save:=>
    params      = @filter_params()
    opts        = @context()
    opts.prefix = @_prefix()  if _.any @scope
    switch @action
      when 'new'  then @Api[@table_name].create params, opts
      when 'edit' then @Api[@table_name].update @$.model.id, params, opts
      else 
        opts.tag = 'success'
        @Api[@table_name][@action] @$.model.id, params, opts
  custom_success:(e,data)=>
    @$.model = data
  new_success:(e,data)=>
    @$.model = data
  edit_success:(e,data)=>
    @$.model = data
  success:(e,data)=>
    @$.pop = false
    @$root.popped = false
  err:(e,data)=>
    @$.errors = null
    @$.errors = data
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
        @$on "#{path}/new"       , @new_success
        @$on "#{path}/create"    , @success
        @$on "#{path}/create#err", @err
      when 'edit'
        @$on "#{path}/update"    , @success
        @$on "#{path}/destroy"   , @success
        @$on "#{path}/update#err", @err
        @$on "#{path}/edit"      , @edit_success if @can_pull('edit')
      else
        @$on "#{path}/#{@action}"        , @custom_success
        @$on "#{path}/#{@action}#success", @success
        @$on "#{path}/#{@action}#err"    , @err
    true
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
  destroy:=>
    name = _.singularize @table_name
    msg  = "Are you sure you wish to destroy this #{name}"
    @Api[@table_name].destroy @$.model, @attrs() if confirm msg
