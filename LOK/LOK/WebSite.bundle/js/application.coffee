$ ->
  setup_socket()
  setup_chart()
  $(window).resize ->
    setup_chart()
  $(window).bind 'beforeunload', (e)->
    message = false
    if true
      message = "Are you sure to leave? make sure you backup the test data."
      e.returnValue = message
    else
      return
    return message
  
  

  
# getters & setters
get_tr_template = ->
  _this = @
  if !@tr_template
    $.get './partials/tr_item.json',(data)->
      _this.tr_template = data
      Mustache.parse(_tr_template);
  return @tr_template


setup_socket = ->
  socket = new WebSocket('ws://192.168.10.36:12356');
  socket.onopen = ->
    socket.send('hello world!');

  socket.onmessage = (event)->
    console.log(window.r = event)
    data = JSON.parse(event.data)
    switch data["type"]
      when "request"
        handle_request(data["data"])
      when "usage"
        handle_usage(data["data"])
  
  socket.onclose = () ->
    console.log('Lost connection! Maybe server is close.');
  
  handle_request = (data)->
    data["limitLength"] = ()->
      return (text, render)->
        return render(text).substr(0,40) + '...';
    el = Mustache.render(get_tr_template(), data);
    $('table tbody').prepend(el)
  
  
  handle_usage = (data)->
    window.cpu_data.datasets[0].data.push data.cpu_usage
    window.cpu_chart.addData([data.cpu_usage],'');
    if window.cpu_chart.datasets[0].points.length > window.chart_max_count
      window.cpu_chart.removeData()
    window.cpu_chart.update()
    
    window.memory_data.datasets[0].data.push data.memory_usage
    window.memory_chart.addData([data.memory_usage>>20],'');
    if window.memory_chart.datasets[0].points.length > window.chart_max_count
      window.memory_chart.removeData()
    window.memory_chart.update()
    
    window.fps_data.datasets[0].data.push data.fps
    window.fps_chart.addData([data.fps],'');
    if window.fps_chart.datasets[0].points.length > window.chart_max_count
      window.fps_chart.removeData()
    window.fps_chart.update()
    
setup_chart = ->
  $.each($('canvas'),->
    el = $(@)
    el.attr
      "width"  : el.parent().width()
      "height" : 200
  )

  cpu_ctx = $("#cpu_chart").get(0).getContext("2d");
  window.cpu_chart = new Chart(cpu_ctx).Line(window.cpu_data, {animation: false});
  memory_ctx = $("#memory_chart").get(0).getContext("2d");
  window.memory_chart = new Chart(memory_ctx).Line(window.memory_data, {animation: false});
  fps_ctx = $("#fps_chart").get(0).getContext("2d");
  window.fps_chart = new Chart(fps_ctx).Line(window.fps_data, {animation: false});


window.chart_max_count = 15;
window.cpu_data = 
  labels: [],
  datasets: [{
              label: "CPU dataset",
              fillColor: "rgba(151,187,205,0.2)",
              strokeColor: "rgba(151,187,205,1)",
              pointColor: "rgba(151,187,205,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#9c0001",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: []
            }]
            
window.memory_data = 
  labels: [],
  datasets: [{
              label: "CPU dataset",
              fillColor: "rgba(216,165,159,0.5)",
              strokeColor: "rgba(216,165,159,1)",
              pointColor: "rgba(216,165,159,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#9c0001",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: []
            }]
            
window.fps_data = 
  labels: [],
  datasets: [{
              label: "CPU dataset",
              fillColor: "rgba(151,187,205,0.2)",
              strokeColor: "rgba(151,187,205,1)",
              pointColor: "rgba(151,187,205,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#9c0001",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: []
            }]