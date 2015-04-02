app.directive 'focusOn', ->
  link: (scope,element,attrs) ->
    scope.$watch attrs.focusOn, ->
      if scope.$eval(attrs.focusOn) == true
        _.defer ->
          element.focus()
      else if element.is(':focus')
        _.defer ->
          element.blur()
