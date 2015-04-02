$directive 'bgImage', ->
  scope:
    "bg_image": "=bgImage"
  link: (scope,element,attrs)->
    element.css 'background-image', "url(#{scope.bg_image})"
