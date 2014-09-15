#
# @license Andrew Brown v1.0.0
# (c) 2013 http://monsterboxpro.com
# License: MIT
#

parameter_name = (root)->
  name = root[0]
  name += '['  + root.slice(1).join('][') + ']' if root.length > 1
  name
has_attached_file = (value)->
  result = false
  if typeof value == 'object' && !(value instanceof File)
    for own k,v of value
      result |= has_attached_file v
  else if typeof value == 'array'
    for vv in v
      result |= has_attached_file vv
  else
    result |= value instanceof File
  return result
form_object_to_form_data = (value,fd=null,root=[]) ->
  fd = new FormData() unless fd
  if typeof value == 'object' && !(value instanceof File)
    for own k,v of value
      form_object_to_form_data v, fd, root.concat [k]
  else if typeof value == 'array'
    for i,vv in value
      form_object_to_form_data vv, fd, root.concat [i]
  else
    return if _.last(root)[0] == '$' # Skip angular attributes like $$hashKey
    fd.append parameter_name(root), value
  fd

class window.ApiBase
  _get:(table_name,action,name,params={},opts={})=>
    params.socket_id = window.socket_id if window.socket_id
    req = @$http
      method : 'GET'
      url    : name
      params : params
    @_callback table_name, req, action, opts
  _post:(table_name,action,name,params={},opts={})=>
    params.socket_id = window.socket_id if window.socket_id
    if has_attached_file(params)
      form_data = form_object_to_form_data(params)
      req = @$http
        method: 'POST'
        url: name
        data: form_data
        transformRequest: angular.identity
        headers:
          'Content-Type': undefined
    else
      req  = @$http.post name, params
    @_callback table_name, req, action, opts
  _put:(table_name,action,name,params,opts={})=>
    params.socket_id = window.socket_id if window.socket_id
    if has_attached_file(params)
      form_data = form_object_to_form_data(params)
      req = @$http
        method: 'PUT'
        url: name
        data: form_data
        transformRequest: angular.identity
        headers:
          'Content-Type': undefined
    else
      req  = @$http.put name, params
    @_callback table_name, req, action, opts
  _delete:(table_name,action,name,params={},opts={})=>
    params.socket_id = window.socket_id if window.socket_id
    req = @$http
      method : 'DELETE'
      url    : name
      params : params
    @_callback table_name, req, action, opts
  _callback:(table_name,req,action,opts)=>
    msg  = "#{table_name}/#{action}"
    msg  = "#{@_scope}/#{msg}" if @_scope
    req.success (data, status, headers, config)=> @$rootScope.$broadcast msg         , data, opts, status, headers, config
    req.error (data, status, headers, config)=>   @$rootScope.$broadcast "#{msg}#err", data, opts, status, headers, config
    req
  _extract_id:(model)=>
    if typeof model is 'string' || typeof model is 'number'
      model
    else
      model.id
  path:(args...)=>
    path = []
    path.push @namespace if @namespace
    #path.push args.shift
    path.push a for a in args
    path = path.join '/'
    "/#{path}"
  constructor:(@$rootScope,@$http)->
    _.each @resources, (options, table_name) =>
      @[table_name] =
        index   : (params,opts)=>       @_get    table_name, 'index'  , @path(table_name)       , params, opts
        new     : (params,opts)=>       @_get    table_name, 'new'    , @path(table_name,'new') , params, opts
        create  : (params,opts)=>       @_post   table_name, 'create' , @path(table_name)       , params, opts
        show    : (model,params,opts)=> @_get    table_name, 'show'   , @path(table_name,@_extract_id(model))        , params, opts
        edit    : (model,params,opts)=> @_get    table_name, 'edit'   , @path(table_name,@_extract_id(model),'edit') , params, opts
        update  : (model,params,opts)=> @_put    table_name, 'update' , @path(table_name,@_extract_id(model))        , params, opts
        destroy : (model,params,opts)=> @_delete table_name, 'destroy', @path(table_name,@_extract_id(model))        , params, opts
      _.each options.collection, (method, action) =>
        name = @path table_name, action
        fun = switch method
          when 'get'     then (params,opts)=> @_get    table_name, action, name, params, opts
          when 'post'    then (params,opts)=> @_post   table_name, action, name, params, opts
          when 'put'     then (params,opts)=> @_put    table_name, action, name, params, opts
          when 'destroy' then (params,opts)=> @_delete table_name, action, name, params, opts
        @[table_name][action] = fun
      _.each options.member, (method, action) =>
        fun = switch method
          when 'get'     then (model,params,opts)=> @_get    table_name, action, @path(table_name, model.id, action), params, opts
          when 'post'    then (model,params,opts)=> @_post   table_name, action, @path(table_name, model.id, action), params, opts
          when 'put'     then (model,params,opts)=> @_put    table_name, action, @path(table_name, model.id, action), params, opts
          when 'destroy' then (model,params,opts)=> @_delete table_name, action, @path(table_name, model.id, action), params, opts
        @[table_name][action] = fun
  scope:(args...)=>
    # Scopes the URL & events
    # Task.scope('stories', story.id).create { name: 'New Task' }
    # Event names will look like: stories/1/tasks/create
    # URL will be: api/v1/stories/1/tasks
    scope = args.join '/'
    result = @prefix scope
    result._scope ?= []
    result._scope.push scope
    result

  prefix:(args...)=>
    # Prefixes the URL
    # Story.prefix('projects/1').create { name: 'New Story' }
    # Event name will look like: stories/create
    # URL will be: api/v1/projects/1/storyes
    clone = new @constructor @$rootScope, @$http
    namespace = args.join '/'
    clone.namespace = "#{@namespace}/#{namespace}"
    clone
