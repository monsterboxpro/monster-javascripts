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

# delimiter - defaults to $
# percision - true | false | clean (dont should decimal if .00)
# seperator - will add seperate for thousands, true == ',' or specific your own.
app.filter 'data_table_currency', ->
  (input,opts={})->
    return unless input
    input = "#{input}"

    opts.seperator ||= ','
    opts.delimiter ||= '$'
    opts.seperator   = ',' if _.isBoolean opts.seperator && opts.seperator is true
    opts.delimiter   = '$' if _.isBoolean opts.delimiter && opts.delimiter is true

    if opts.percision
      if opts.percision is 'clean'
        input = String Math.round(Number(input) * 100) / 100 
        input = input.replace /\.00$/, '' if input.match /\.00$/
      else if opts.percision is true
        input = String Math.round(Number(input) * 100) / 100 

    input = input.replace /\B(?=(\d{3})+(?!\d))/g, opts.seperator if opts.seperator

    "#{opts.delimiter}#{input}"


app.filter 'data_table_date', ->
  (input,opts={})->
    return unless input
    if moment(input).isSame(new Date,'year')
      moment(input).format 'MMM D'
    else
      moment(input).format 'MMM D YYYY'

# 24 hous time
# kind - smart date (exclude date if implied)
# format
app.filter 'data_table_datetime', ->
  (input,opts={})->
    return unless input
    if moment(input).isSame(new Date,'day')       then moment(input).format 'h:mma'
    else if moment(input).isSame(new Date,'year') then moment(input).format 'MMM-DD h:mma'
    else
      moment(input).format('YYYY MMM-DD h:mma')

app.filter 'data_table_duration', ->
  (input) ->
    minutes = Math.floor(input / 60)
    seconds = input - minutes * 60
    "#{minutes}.#{seconds} mins"
