app.filter 'highlight', ->
  (text, search, caseSensitive) ->
    if search or angular.isNumber(search)
      text = text.toString()
      search = search.toString()
      if caseSensitive
        text.split(search).join "<span class=\"ui-match\">" + search + "</span>"
      else
        text.replace new RegExp(search, "gi"), "<span class=\"ui-match\">$&</span>"
    else
      text
