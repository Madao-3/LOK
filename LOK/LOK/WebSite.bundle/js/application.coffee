$ ->
  setup_socket()
  setup_chart()
  

  
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
    window.cpu_chart.addData([data.cpu_usage],'');
    window.cpu_chart.update()
    window.memory_chart.addData([data.memory_usage >> 20],'');
    window.memory_chart.update()
    
    
setup_chart = ->
  cpu_ctx = $("#cpu_chart").get(0).getContext("2d");
  window.cpu_chart = new Chart(cpu_ctx).Line(window.cpu_data, {animation: false});
  memory_ctx = $("#memory_chart").get(0).getContext("2d");
  window.memory_chart = new Chart(memory_ctx).Line(window.memory_data, {animation: false});

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
              fillColor: "rgba(151,187,205,0.2)",
              strokeColor: "rgba(151,187,205,1)",
              pointColor: "rgba(151,187,205,1)",
              pointStrokeColor: "#fff",
              pointHighlightFill: "#9c0001",
              pointHighlightStroke: "rgba(151,187,205,1)",
              data: []
            }]