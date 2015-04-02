$service 'Map', '$q', class
  opts:
    map:=>
      mapTypeId: google.maps.MapTypeId.ROADMAP
      panControl: false
      streetViewControl: false
      mapTypeControl: true
      mapTypeControlOptions:
        style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
      zoomControl: false
    directions:
      suppressMarkers: true
  constructor:->
    deferred = @$q.defer()
    @promise = deferred.promise
    window.init_gmaps = -> deferred.resolve()
    script = document.createElement('script')
    script.type = 'text/javascript'
    gmaps_api = 'AIzaSyCrOBIUEILY4rk5jwKl1ZceoztwjRaV2cc'
    script.src = "https://maps.googleapis.com/maps/api/js?key=#{gmaps_api}&callback=init_gmaps&libraries=places"
    document.body.appendChild(script)
  setup:(element)=>
    el   = element.find('.map')[0]
    new google.maps.Map el, @opts.map
  marker:(map,name,loc)=>
    new google.maps.Marker
      position : @lat_long(loc)
      map      : map
      icon     : "/marker_#{name}.png"
  lat_long:(d)-> new google.maps.LatLng d.latitude, d.longitude
  route:(service,directions,start,end,waypoints=[])=>
    req =
      origin:      start.position
      destination: end.position
      waypoints:   waypoints
      optimizeWaypoints: true
      travelMode:  google.maps.TravelMode.DRIVING
    service.route req, (result, status)=>
      if status is google.maps.DirectionsStatus.OK
        directions.setDirections result
  # center's map based on current geo location if possible
  set_current:(map,zoom=9)=>
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) =>
        loc = @lat_long position.coords
        map.setCenter loc
        map.setZoom zoom
    else
      loc = new google.maps.LatLng(37.4419, -122.1419) # Palo Alto
      map.setCenter loc
      map.setZoom zoom
  calc_distance:(start,end,callback)=>
    return null unless start and end
    service = new google.maps.DirectionsService()
    deferred = @$q.defer()
    deferred.promise
    route =
      origin:      @lat_long start
      destination: @lat_long end
      travelMode: google.maps.TravelMode.DRIVING
    service.route route, (result, status) =>
      if status == google.maps.DirectionsStatus.OK
        distance = 0
        distance += leg.distance.value for leg in result.routes[0].legs
        callback distance
        deferred.resolve()
      else
        deferred.reject()
