app.directive 'draggablePopup', ->
  (scope,element,attrs)->
    element.draggable
      handle: '.popup_heading'
    scope.$on 'reset_popup_position', ->
      element.removeAttr 'style'
