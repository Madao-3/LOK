window.Application = 
  init : ->
    @setup_socket()
    @setup_chart()
  requests_list : new Vue({
    el: '#requests_list',
    data: 
      list: []
  })
  
  thread_count : new Vue({
    el: '#thread_count'
    data:
      count: 0
  })
  
  viewcontroller_path : new Vue({
    el: '#viewcontroller_path'
    data:
      path: ""
  })
  
  setup_socket : ->
    _this = @
    # @socket = new WebSocket("ws://#{location.hostname}:#{+(location.port)+1}")
    @socket = new WebSocket("ws://192.168.10.113:12356")
    @socket.onopen = ->
      _this.socket.send('hello world!')

    @socket.onmessage = (event)->
      data = JSON.parse(event.data)
      switch data["type"]
        when "request"
          _this.handle_request(data["data"])
          break
        when "usage"
          _this.handle_usage(data["data"])
          break
  
    @socket.onclose = () ->
      console.log('Lost connection! Maybe server is close.')
      setTimeout(->
        _this.setup_socket()
      ,100)

  handle_request : (data)->
    window.xx = @requests_list
    @requests_list.list.unshift data
  
  
  handle_usage : (data)->
    @thread_count.count = data.thread_count
    @viewcontroller_path.path = data.viewcontroller_path
    if @memory_chart.getContext
      @setup_chart()
      return
    @cpu_data.datasets[0].data.push data.cpu_usage
    @cpu_chart.addData([data.cpu_usage],'')
    if @cpu_chart.datasets[0].points.length > @chart_max_count
      @cpu_chart.removeData()
    @cpu_chart.update()
    
    @memory_data.datasets[0].data.push data.memory_usage
    @memory_chart.addData([data.memory_usage>>20],'')
    if @memory_chart.datasets[0].points.length > @chart_max_count
      @memory_chart.removeData()
    @memory_chart.update()
    
    @fps_data.datasets[0].data.push data.fps
    @fps_chart.addData([data.fps],'')
    if @fps_chart.datasets[0].points.length > @chart_max_count
      @fps_chart.removeData()
    @fps_chart.update()
    
  setup_chart : ->
    $.each($('canvas'),->
      el = $(@)
      el.attr
        "width"  : el.parent().width()
        "height" : 200
    )
    option = 
      pointDot      : false
    cpu_ctx = $("#cpu_chart").get(0).getContext("2d")
    @cpu_chart = new Chart(cpu_ctx).Line(@cpu_data, {
      scaleLabel : "<%=value%>%"
      pointDot      : false
    })
    memory_ctx = $("#memory_chart").get(0).getContext("2d")
    @memory_chart = new Chart(memory_ctx).Line(@memory_data, {
      scaleLabel : "<%=value%>MB"
      pointDot      : false
    })
    fps_ctx = $("#fps_chart").get(0).getContext("2d")
    @fps_chart = new Chart(fps_ctx).Line(@fps_data, option)
    
  
  event_bind : ->
    $('.nav-tabs a').click (e)->
      e.preventDefault()
      $(this).tab('show')
    $(window).bind 'beforeunload', (e)->
      message = false
      if true
        message = "Are you sure to leave? make sure you backup the test data."
        e.returnValue = message
      else
        return
      return message
  
  chart_max_count : 150
  cpu_data : 
    labels: [],
    datasets: [{
      fillColor     : "rgba(151,187,205,0.2)"
      strokeColor   : "rgba(151,187,205,1)"
      data: []
      }]
            
  memory_data :
    labels: [],
    datasets: [{
                backgroundColor:"#F7464A"

                fillColor: "rgba(216,165,159,0.5)"
                strokeColor: "rgba(216,165,159,1)"
                scaleLabel: "<%=value%>MB"
                data: []
              }]
            
  fps_data :
    labels: [],
    datasets: [{
        fillColor     : "rgba(151,187,205,0.2)"
        strokeColor   : "rgba(151,187,205,1)"
        data: []
      }]



  
  






Chart.defaults.global = 
  animation: true
  animationSteps: 60
  animationEasing: "easeOutQuart"
  showScale: true
  scaleOverride: false
  scaleSteps: null
  scaleStepWidth: null
  scaleStartValue: null
  scaleLineColor: "rgba(0,0,0,.1)"
  scaleLineWidth: 1
  scaleShowLabels: true
  scaleLabel: "<%=value%>"
  scaleIntegersOnly: false
  scaleBeginAtZero: false
  scaleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"
  scaleFontSize: 12,
  scaleFontStyle: "normal",
  scaleFontColor: "#666",
  responsive: true
  maintainAspectRatio: true
  showTooltips: false
  customTooltips: false
  tooltipEvents: ["mousemove", "touchstart", "touchmove"]
  tooltipFillColor: "rgba(0,0,0,0.8)"
  tooltipFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"
  tooltipFontSize: 14
  tooltipFontStyle: "normal"
  tooltipFontColor: "#fff"
  tooltipTitleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif"
  tooltipTitleFontSize: 14
  tooltipTitleFontStyle: "bold"
  tooltipTitleFontColor: "#fff"
  tooltipYPadding: 6
  tooltipXPadding: 6
  tooltipCaretSize: 8
  tooltipCornerRadius: 6
  tooltipXOffset: 10
  tooltipTemplate: ""
  multiTooltipTemplate: ""
  onAnimationProgress: null
  onAnimationComplete: null
  
$ ->
  Application.init()