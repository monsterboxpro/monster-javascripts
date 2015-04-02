$directive 'uiActive', '$state',
  ($state)->
    (scope,element,attrs)->
      update = ->
        if $state.current.templateUrl
          name =
          if attrs.uiBy and attrs.uiBy is 'name'
            $state.current.name
          else
            $state.current.templateUrl.replace /\//g, '_'
          reg = new RegExp attrs.uiActive
          if name.match(reg)
            element.addClass 'active'
          else
            element.removeClass 'active'
        return
      @$$setStateInfo = (newState) ->
        state = $state.get newState, stateContext(element)
        update()
        return
      scope.$on '$stateChangeSuccess', update
