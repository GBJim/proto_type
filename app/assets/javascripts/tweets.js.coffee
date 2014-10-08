# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
console.log(gon.data)


draw = ->
  chart = c3.generate(
    data:
      x: "x"
      
    
      columns: gon.data

    axis:
      x:
        type: "timeseries"
        tick:
          format: "%Y-%m-%d"
  )


$(document).on('ready',draw);