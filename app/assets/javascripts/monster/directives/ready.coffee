app.directive 'ready', ->
  (scope, element, attrs) ->
    element.removeClass 'not_ready'
