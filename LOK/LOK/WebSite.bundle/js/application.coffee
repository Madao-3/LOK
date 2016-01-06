window.Application = 
  init : ->
    @setup_socket()
    @setup_chart()
    @event_bind()
    Vue.filter 'filter_request', (list,filter)->
      if filter != 'all'
        l = []
        for i in list
          if i.responseMIMEType.match filter
            l.push i
        return l
      else
        return list
  
  

  

  requests_list : new Vue({
    el: '#requests_list',
    data: 
      list: []
      filter_type: "all"
    methods:
      params_list_html: (request)->
        url         = new URL(request.requestURLString)
        path_list   = url.pathname.split('/')
        params_list = url.search.substr(1,url.search.length).split('&')
        html_string = ""
        for path,index in path_list
          continue unless path.length
          className = 'info'
          if path[path.length-1] == "s"
            className = 'primary'
          html_string += "<label class='label label-#{className}'>#{path}</label>"
        if params_list.length > 1
          html_string += "<label class='label label-warning'>?</label>"
        for param,index in params_list
          params = param.split('=')
          html_string += "<label class='label label-success'  data-toggle='tooltip' data-placement='bottom' title='#{params[1]}'>#{params[0]}</label>"
        html_string
        
      date_format: (request)->
        moment.unix(+request.datetime).format("h:mm:ss a")
        
      show_content: (request)->
        $('.request-result').hide()
        window.fuck = request
        switch request.responseMIMEType
          when 'application/json'
            $('#request-result-block').animate(
              right : 0
            ,300)
            .find('.title').text("#{request.requestHTTPMethod} - #{request.requestURLString}")
            data = JSON.parse request.JSONString
            $.hulk '#JSON-body', data, (data)->
              console.log(data)
              return
            break
          when 'image/jpeg'
            image = $('<img>')
            image.attr('src',request.requestURLString)
            $('#request-result-modal').modal('show')
            .find('.modal-title').html("<a href='#{request.requestURLString}' target='blank'>#{request.requestURLString.slice(0,40)+"..."}</a>")
            .end().find('.request-result-body').hide()
            .end().find('.image-body').show().html(image)
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
    if (number < 10) 
      return '0' + number
    return number
  setup_socket : ->
    _this = @
    # @socket = new WebSocket("ws://#{location.hostname}:#{+(location.port)+1}")
    @socket = new WebSocket("ws://192.168.10.183:12356")
    @socket.onopen = ->
      _this.socket.send('hello world and what is your name?')

    @socket.onmessage = (event)->
      # console.log event
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
          _this.base_info.start_time  = data.start_time
          setTimeout(->
            $("#start_time").text(moment.unix(+data.start_time).fromNow())
          ,100)
          setInterval(->
            $("#start_time").text(moment.unix(+data.start_time).fromNow())
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
    # @cpu_chart.update()
    
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
      showTooltips  : false
    cpu_ctx = $("#cpu_chart").get(0).getContext("2d")
    @cpu_chart = new Chart(cpu_ctx).Line(@cpu_data, {
      scaleLabel : "<%=value%>%"
      pointDot      : false
      showTooltips: false
    })
    memory_ctx = $("#memory_chart").get(0).getContext("2d")
    @memory_chart = new Chart(memory_ctx).Line(@memory_data, {
      scaleLabel : "<%=value%>MB"
      pointDot   : false
      animation  : false 
      showTooltips: false
    })
    fps_ctx = $("#fps_chart").get(0).getContext("2d")
    @fps_chart = new Chart(fps_ctx).Line(@fps_data, option)

  # filter_request_list : (type)->
    

  event_bind : ->
    _this = @
    

    $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
    })
    
    $('#request_filter li a').on "click",->
      _this.requests_list.filter_type = $(@).text()
    
    $('#request-result-block .close').click ->
      $('#request-result-block').animate({
        right: -$(window).width()
      },300)

    $('.result-block-bottom .btn').click ->
      data = $.hulkSmash('#JSON-body')
      _this.socket.send(JSON.stringify(data))
      $('#request-result-block').animate({
        right: -$(window).width()
      },300)
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
  
  data_store : ->
    
  
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

  
$ ->
  Application.init()