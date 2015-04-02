$directive 'monsterFile', ->
  scope:
    model: '=monsterFile'
  link:(scope,element,attrs)->
    element.on 'change', (e)->
      preview     = element.parent().find('.preview')
      scope.model = e.target.files[0]
      reader      = new FileReader()
      reader.readAsDataURL e.target.files[0]
      reader.onload = (e)=>
        console.log e.target.result
        preview.css 'background-image', "url(#{e.target.result})"
      scope.$apply()
