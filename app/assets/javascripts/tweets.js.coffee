# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



renderLineChart = ->
  lineChart = c3.generate(
    bindto: '#line-chart'
    data:
      x: "x"
      
    
      columns: gon.daily_emotion
      colors:
        anger: "#D40000"
        anticipation: "#FFA854"
        disgust: "#FF54FF"
        fear: "#008000"
        joy: "#FFFF54"
        sadness: "#5151FF"
        surprise: "#59BDFF"
        trust: "#54FF54"


    axis:
      x:
        type: "timeseries"
        tick:
          format: "%Y-%m-%d"
  )


renderPieChart = ->
  pieChart = c3.generate(
    bindto:'#pie-chart'
    data:
      columns: gon.total_emotion
      colors:
        anger: "#D40000"
        anticipation: "#FFA854"
        disgust: "#FF54FF"
        fear: "#008000"
        joy: "#FFFF54"
        sadness: "#5151FF"
        surprise: "#59BDFF"
        trust: "#54FF54"
 
      type: "pie"
      onclick: (d, i) ->
        console.log "onclick", d, i
        return

      onmouseover: (d, i) ->
        console.log "onmouseover", d, i
        return

      onmouseout: (d, i) ->
        console.log "onmouseout", d, i
      
  )


   
renderMap =  ->


  overlay = new google.maps.OverlayView()
  
  # Add the container when the overlay is added to the map.
  overlay.onAdd = ->
    layer = d3.select(@getPanes().overlayLayer).append("div").attr("class", "stations")
    
    # Draw each marker as a separate SVG element.
    # We could use a single SVG, but what size would it have?
    overlay.draw = ->
      # update existing markers
      
      # Add a circle.
      
      # Add a label.
      transform = (d) ->
        d = new google.maps.LatLng(d.value[2], d.value[1])
        d = projection.fromLatLngToDivPixel(d)
        d3.select(this).style("left", (d.x - padding) + "px").style "top", (d.y - padding) + "px"

      get_color = (d) ->
        d.value[0]
      
      projection = @getProjection()
      padding = 10
      marker = layer.selectAll("svg").data(d3.entries(gon.locations)).each(transform).enter().append("svg:svg").each(transform).attr("class", "marker")
      marker.append("svg:circle").attr("r", 4.5).attr("cx", padding).attr("class",get_color).attr "cy", padding
     



  
  map = new google.maps.Map(d3.select("#map").node(),
  zoom: 2
  center: new google.maps.LatLng(37.76487, -122.41948)
  mapTypeId: google.maps.MapTypeId.TERRAIN)
  # Bind our overlay to the map…
  overlay.setMap map




$(document).on('ready',renderLineChart);
$(document).on('ready',renderPieChart);
$(document).on('ready',renderMap);