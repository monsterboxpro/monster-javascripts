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
window.$controller = (name, args..., definition) ->
  args.unshift '$scope': '$'
  args.push 'Event'
  args.push 'Api'
  if $('body').hasClass('home_pages')
    args.push '$state'
    args.push '$stateParams'
  names = name.split '/'
  injection_args = args_to_injection_parameters args
  super_def = class extends definition
    constructor:->
      set_args args, @, arguments
      @_controller = names[0]
      @_action     = names[1]
      @$export 'stop'
      @$root = @$.$root
      super
    $export: (args...)=>
      for arg in args
        @$[arg] = @[arg]
    $emit: (args...)=>      @$.$emit args...
    $broadcast: (args...)=> @$.$broadcast args...
    $on: (args...) =>       @$.$on args...
    stop:(event)=>
      event.stop()
      @$
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
