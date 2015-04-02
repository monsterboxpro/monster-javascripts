$controller 'monster-directives/google_autocomplete', '$element', '$attrs','Map', class
  constructor:->
    @Map.promise.then @render
  render:=>
    @geocoder     = new google.maps.Geocoder()
    @autocomplete = new google.maps.places.Autocomplete @$element[0]
    @service      = new google.maps.places.AutocompleteService()

    @autocomplete.bindTo 'bounds', @$.map if @$.map
    google.maps.event.addListener @autocomplete, 'place_changed', @place_changed
    @$element.on 'keypress', @keypress
    @$element.on 'blur', => _.delay @on_blur, 250
  place_is_selected: false
  place_changed:=>
    @place = @autocomplete.getPlace()
    return unless @place.geometry
    @$.set_view @place
    @$.$apply()
    @$root.$broadcast 'update_route',
      start: @$.model.start_location
      end: @$.model.end_location

    @place_is_selected = true
  keypress:=>
    @place_is_selected = false
    true
  on_blur:=>
    unless @place_is_selected
      attrs =
        input:  @$element.val()
        offset: @$element.val().length
      attrs.bounds = @$.map.getBounds() if @$.map
      @service.getPlacePredictions attrs, @predictions_success
  predictions_success:(predictions) ->
    if predictions.length
      places_service = new google.maps.places.PlacesService(@$.map)
      attrs = { reference: predictions[0].reference }
      places_service.getDetails attrs, @places_success
  places_success:(details)=>
    @place_is_selected = true
    @$element.val details.formatted_address
    @$.set_view details
    @$.$apply() unless @$.$$phase

$directive 'monsterGoogleAutocomplete', ->
  scope: true
  require: '?ngModel'
  controller:  'monster-directives/google_autocomplete'
  link : (scope, element, attrs, ngModelController)->
    parser = (place)->
      return null unless place && place.geometry

      latitude  = place.geometry.location.lat()
      longitude = place.geometry.location.lng()

      console.log place
      comp = place.address_components
      for attrs in comp
        switch attrs.types[0]
          when 'street_number'               then street_number               = attrs.long_name
          when 'route'                       then route                       = attrs.long_name
          when 'neighborhood'                then neighborhood                = attrs.long_name
          when 'sublocality_level_1'         then sublocality_level_1         = attrs.long_name
          when 'locality'                    then locality                    = attrs.long_name
          when 'administrative_area_level_1' then administrative_area_level_1 = attrs.long_name
          when 'country'                     then country                     = attrs.long_name
          when 'postal_code'                 then postal_code                 = attrs.long_name
      #location                    : new google.maps.LatLng(latitude,longitude)
      latitude                    : latitude
      longitude                   : longitude
      street_number               : street_number
      route                       : route
      neighborhood                : neighborhood
      sublocality_level_1         : sublocality_level_1
      locality                    : locality
      administrative_area_level_1 : administrative_area_level_1
      country                     : country
      postal_code                 : postal_code
    formatter = (value)->
      console.log value
      if value
        return value.address
      else
        return ''
    ngModelController.$parsers.push    parser
    ngModelController.$formatters.push formatter
    scope.set_view = (place)-> 
      ngModelController.$setViewValue place

