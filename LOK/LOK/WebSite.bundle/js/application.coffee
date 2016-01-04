window.Application = 
  init : ->
    @setup_socket()
    @setup_chart()
  requests_list : new Vue({
    el: '#requests_list',
    data: 
      list: []
  })
  
  base_info : new Vue({
    el: '#base_info'
    data:
      count: 0
      path: ""
      app_name: ""
      memory_size: 0
      start_time: null
      cpu_percent: 0
      memory_percent: 0
      fps: 0
  })
  
  UTCDateString : (date)->
    year  = date.getUTCFullYear() 
    month = @pad(date.getUTCMonth() + 1) 
    dates = @pad(date.getUTCDate())
    hours = @pad(date.getUTCHours())
    mins  = @pad(date.getUTCMinutes())
    sec   = @pad(date.getUTCSeconds());
    # 2011-12-17T09:24:17Z
    return "#{year}-#{month}-#{dates}T#{hours}:#{mins}:#{sec}Z"
  
  pad : (number)->
    console.log number
    if (number < 10) 
      return '0' + number
    return number
  setup_socket : ->
    _this = @
    @socket = new WebSocket("ws://#{location.hostname}:#{+(location.port)+1}")
    # @socket = new WebSocket("ws://192.168.10.33:12356")
    @socket.onopen = ->
      _this.socket.send('hello world and what is your name?')

    @socket.onmessage = (event)->
      console.log event
      data = JSON.parse(event.data)
      switch data.type
        when "request"
          _this.handle_request(data.data)
          break
        when "usage"
          _this.handle_usage(data.data)
          break
        when "base_info"
          _this.base_info.app_name    = data.name
          _this.base_info.memory_size = data.memory_size
          date = new Date data.start_time.replace('GMT','')
          _this.base_info.start_time = _this.UTCDateString date;
          setTimeout(->
            $("time.timeago").timeago()
          ,100)
          setInterval(->
            $("time.timeago").timeago()
          ,60000)
          break
    @socket.onclose = () ->
      console.log('Lost connection! Maybe server is close.')
      setTimeout(->
        _this.setup_socket()
      ,100)

  handle_request : (data)->
    @requests_list.list.unshift data
  
  
  handle_usage : (data)->
    @base_info.cpu_percent    = data.cpu_usage.toFixed(2)
    @base_info.memory_percent = (data.memory_usage / (1024*1024*10)).toFixed(2)
    @base_info.fps            = data.fps
    @base_info.count = data.thread_count
    @base_info.path = data.viewcontroller_path
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
      fillColor     : "rgba(151,187,205,0.7)"
      strokeColor   : "rgba(151,187,205,1)"
      data: []
      }]
            
  memory_data :
    labels: [],
    datasets: [{
                fillColor: "rgba(216,165,159,0.7)"
                strokeColor: "rgba(216,165,159,1)"
                data: []
              }]
            
  fps_data :
    labels: [],
    datasets: [{
        fillColor     : "rgba(216,204,134,0.7)"
        strokeColor   : "rgba(216,204,134,1)"
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