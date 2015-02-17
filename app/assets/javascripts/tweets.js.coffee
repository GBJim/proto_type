# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



renderNewLineChart = ->
  csv =     "Date,Temperature\n" +
    "2008-05-07,75\n" +
    "2008-05-08,70\n" +
    "2008-05-09,80\n"
  new Dygraph(document.getElementById('newLineChart'), gon.test)



renderLineChart = ->
  console.log(gon.test);
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


   

renderFace = ->
  singleScale = d3.scale.linear().domain([0,1]).range([0.2,1]) 
  dualScale = d3.scale.linear().domain([0,1]).range([-1,1])
  surpriseScale = d3.scale.linear().domain([0,1]).range([0.9,1]) 
  joyScale = d3.scale.pow(2).range([-0.8,2]) 

  c = d3.chernoff().face((d) ->
      singleScale(d.anticipation)   #Anticipation
  ).hair((d) ->
     joyScale(d.anger)   #Anger
  ).mouth((d) ->
    joyScale(d.joy)   #Joy
  ).nosew((d) ->
      singleScale(d.trust)  #trust
  ).noseh((d) ->
      singleScale(d.disgust)  #disgust
  ).eyew((d) ->
       surpriseScale(d.surprise)  #surprise
  ).eyeh((d) ->
      singleScale(d.fear) #fear
  ).brow((d) ->
    dualScale(d.sadness)   #sadness
  )
  svg = d3.select("#face-one").append("svg:svg").attr("height", 200).attr("width", 200)
  dat = [gon.face]
  svg.selectAll("g.chernoff").data(dat).enter().append("svg:g").attr("class", "chernoff").attr("transform", (d, i) ->
    "scale(1." + i + ")translate(" + (i * 100) + "," + (i * 100) + ")"
  ).call c
  


colorFace = ->
  colorScale = d3.scale.linear().domain([0,1]).range(["#A67352","green"]);
  d3.select(".skin-1").style("fill",colorScale(gon.disgust));

#$(document).on('ready',renderLineChart);
#$(document).on('ready',renderPieChart);
#$(document).on('ready',renderMap);
$(document).on('ready',renderFace);
$(document).on('ready',colorFace);
#$(document).on('ready',renderNewLineChart);
