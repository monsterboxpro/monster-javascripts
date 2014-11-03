args_to_injection_parameters = (args) ->
  _.flatten args.map (arg) ->
    if typeof arg == 'object'
      attr for attr of arg
    else
      arg
set_args = (args,target,arguments_list) ->
  for arg_name, i in args
    if typeof arg_name == 'object'
      for attr of arg_name
        target[arg_name[attr]] = arguments_list[i]
    else
      target[arg_name] = arguments_list[i]
window.$mkcontroller = (args..., definition)->
  args.unshift '$scope': '$' unless typeof(args[0]) == 'object' && args[0]['$scope']
  class extends definition
    constructor:->
      set_args args, @, arguments
      @_events = []
      @$export 'stop'
      @$root = @$.$root
      super
    $export: (args...)=>
      for arg in args
        @$[arg] = @[arg]
    $emit: (args...)=>      @$.$emit args...
    $broadcast: (args...)=> @$.$broadcast args...
    $on: (args...) =>       @_events.push @$.$on args...
    stop:(event)=>
      event.stop()
      @$
    _register:=>
      super
      @$on '$destroy', @_unregister
    _unregister:=>
      for fn in @_events
        fn()
window.$controller = (name, args..., definition) ->
  args.unshift '$scope': '$'
  args.push 'Event'
  args.push 'Api'
  if $('body').hasClass('home_pages') || $('body').hasClass('app_pages')
    args.push '$state'
    args.push '$stateParams'
  names = name.split '/'
  injection_args = args_to_injection_parameters args
  super_def = class extends $mkcontroller args..., definition
    constructor:->
      @_controller = names[0]
      @_action     = names[1]
      super
  app.controller name, [injection_args..., super_def]
window.$service = (name, args..., definition) ->
  args.unshift '$http'
  args.unshift '$rootScope'
  injection_args = args_to_injection_parameters args
  super_def = class extends definition
    constructor:->
      set_args args, @, arguments
      super
  app.service name, [injection_args..., super_def]
window.$filter = (name, parser)->
  wrapped_parser = ->
    (input)->
      return if input == undefined
      parser input
  app.filter name, wrapped_parser
window.$directive = (name, args..., definition) ->
  app.directive name, [args...,definition]
