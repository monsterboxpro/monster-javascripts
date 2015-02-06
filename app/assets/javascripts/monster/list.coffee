class window.List
  scope: []
  pull        : false
  popups      : false
  root        : false
  search      : false
  action : 'index'
  collection_name: null
  attrs: => {}
  constructor:->
    @collection = []
    @table_name = @_controller unless @table_name
    @_register()
    if @popups is true
      name = @collection_name || @table_name
      @$.pop =
        show: if @Event[name] && @Event[name].show then @Event[name].show else @Event.template(name,'show')
        new:  if @Event[name] && @Event[name].new  then @Event[name].new  else @Event.template(name,'new')
        edit: if @Event[name] && @Event[name].edit then @Event[name].edit else @Event.template(name,'edit')
    if @search is 'location'
      search = @$location.search()
      @$.search     = search.search       if search.search
      @$.pagination = {page: search.page} if search.page
    @reindex() if @pull
    @$.$watch 'search', _.debounce(@update_search, 500) if @search
    @index_success null, @data() if @data
    @$export 'sort',
             'destroy'
    @$.loading = true
    @$.predicate =
      name: 'id'
      dir: 'asc'
    @reindex = _.debounce @reindex, 100
  sort:(name)=>
    dir = if @$.predicate.name is name
      if @$.predicate.dir == 'desc' then 'asc' else 'desc'
    else 
      'asc'
    @$.predicate = {name: name, dir: dir}
    @$location.search 'sort', "#{name},#{dir}"
    @$.sortable = true
    @reindex()
  update_search:(val,old)=>
    if old != val
      if @search is 'location'
        if val != ''
          @$location.search 'search', val
        else
          @$location.search 'search', null
      if @$.pagination
        @$.pagination.page = 1
        @$location.search 'page', null
      @reindex() if @pull
  reindex:=>
    attrs = @attrs()
    if @$.pagination && @$.pagination.page
      attrs.page = @$.pagination.page
    if @search && @$.search
      attrs.search = @$.search
    if @$.sortable
      attrs.sort   = @$location.search().sort
    if @$.pagination
      if @$.pagination.page is 1
        @$location.search 'page', null
      else
        @$location.search 'page', @$.pagination.page
    @$.loading = true
    @Api[@table_name][@action] attrs
  destroy:(model)=>
    name = _.singularize @table_name
    msg  = "Are you sure you wish to destroy this #{name}"
    @Api[@table_name].destroy model, @attrs() if confirm msg
  index_success:(e,data,opts,status,headers,config)=>
    @$.loading = false
    pagination = headers('X-Pagination')
    if pagination
      @$.pagination = JSON.parse(pagination)
    name = @collection_name || @table_name
    if @root
      @$root[name] = data
    else
      @$[name] = data
    @collection = @$[name]
  create_success:(e,data)=>  _.create  @collection, data
  update_success:(e,data)=>  _.update  @collection, data
  destroy_success:(e,data)=> _.destroy @collection, data
  _register:=>
    path = @table_name
    path = [@_prefix(),name].join '/'  if _.any @scope
    @$on "#{path}/#{@action}", @index_success

    name = @collection_name || @table_name
    path = name
    path = [@_prefix(),name].join '/'  if _.any @scope

    @$on "#{path}/create"    , @create_success
    @$on "#{path}/update"    , @update_success
    @$on "#{path}/destroy"   , @destroy_success
    if @pull
      @$.$watch 'pagination.page', (new_val,old_val)=>
        @reindex() if old_val != undefined && new_val != old_val
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'

class window.PusherList
  scope: []
  pull: false
  popups: false
  root   : false
  action : 'index'
  collection_name: null
  channel: ''
  constructor:->
    @collection = []
    @table_name = @_controller unless @table_name
    @_register()
    if @popups is true
      @$.pop =
        new:  if @Event[@table_name] && @Event[@table_name].new  then @Event[@table_name].new  else @Event.template(@table_name,'new')
        edit: if @Event[@table_name] && @Event[@table_name].edit then @Event[@table_name].edit else @Event.template(@table_name,'edit')
    @Api[@table_name][@action]() if @pull
    @index_success null, @data() if @data
    @$.destroy = @destroy
  destroy:(model)=>
    name = _.singularize @table_name
    msg  = "Are you sure you wish to to destroy this #{name}"
    @Api[@table_name].destroy model if confirm msg
  index_success:(e,data)=>
    name = @collection_name || @table_name
    if @root
      @$root[name] = data
    else
      @$[name] = data
    @collection = @$[name]
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
    @$on "#{path}/#{@action}", @index_success
    channel = if _.isString(@channel) then @channel else @channel()
    @Pusher.subscribe  channel
    @Pusher.$on channel, "#{path}/create" , @create_success
    @Pusher.$on channel, "#{path}/update" , @update_success
    @Pusher.$on channel, "#{path}/destroy", @destroy_success
    @$on '$destroy', @_unregister
  _prefix:=>
    path = _.map @scope, (s)=> "#{_.pluralize(s)}/#{@$[s].id}"
    path.join '/'
    project_id = @$stateParams.project_id
    if project_id
      path = @table_name
      path = [@_prefix(),@table_name].join '/'  if _.any @scope
      key = "private-projects.#{project_id}"
      @Pusher.$off key, "#{path}/create" , @create_success
      @Pusher.$off key, "#{path}/update" , @update_success
      @Pusher.$off key, "#{path}/destroy", @destroy_success

# Uunsure if this is ever used anymore.
class window.SearchList extends List
  constructor:->
    @$export 'is_first_page',
             'has_more_pages',
             'next_page',
             'previous_page'
    @$.pagination ?=
      page        : 1
      pages       : 0
      entries     : 0
      per_page    : 0
      start_entry : 0
      end_entry   : 0
    @search  = _.debounce @search, 500
    @reindex = _.debounce @reindex, 10
    @previous_term = ''

    if window.history && window.history.state
      state              = window.history.state
      @$.search_term     = state.search
      @previous_term     = state.search
      @sort_attrs        = state.sort
      @$.pagination.page = state.page
      @reindex()

    @$.$watch 'search_term', @search
    @$on 'data_sort', @sort
    super
  set_state:=>
    if window.history && window.history.replaceState
      state =
        page: @$.pagination.page
        search: @$.search_term
        sort: @sort_attrs
      history.replaceState state, 'search'
  sort:(e,data)=>
    @sort_attrs = data
    @reindex()
  next_page:=>
    return unless @has_more_pages()
    @$.pagination.page++
    @reindex()
  previous_page:=>
    return if @is_first_page()
    @$.pagination.page--
    @reindex()
  search:=>
    @$.pagination.page = 1
    term = @$.search_term
    if term != @previous_term
      @previous_term = term
      @reindex()
  reindex:=>
    @set_state()
    attrs = {}
    term = @$.search_term
    attrs.search = @$.search_term if term && term.length >= 1
    attrs.page = @$.pagination.page
    if @sort_attrs
      attrs['sort[column]']      = @sort_attrs.column
      attrs['sort[direction]']   = @sort_attrs.direction
      attrs['sort[cycle_index]'] = @sort_attrs.cycle_index
    if @search_attrs
      _.extend attrs, @search_attrs()
    @Api[@table_name][@action_name] attrs
    @$.$apply()
  is_first_page:=> @$.pagination.page == 1
  has_more_pages:=> @$.pagination.entries > @$.pagination.end_entry
