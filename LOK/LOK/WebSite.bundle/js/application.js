// Generated by CoffeeScript 1.10.0
(function() {
  window.Application = {
    init: function() {
      this.setup_socket();
      return this.setup_chart();
    },
    requests_list: new Vue({
      el: '#requests_list',
      data: {
        list: []
      }
    }),
    base_info: new Vue({
      el: '#base_info',
      data: {
        count: 0,
        path: "",
        app_name: "",
        memory_size: 0,
        start_time: null,
        cpu_percent: 0,
        memory_percent: 0,
        fps: 0
      }
    }),
    UTCDateString: function(date) {
      var dates, hours, mins, month, sec, year;
      year = date.getUTCFullYear();
      month = this.pad(date.getUTCMonth() + 1);
      dates = this.pad(date.getUTCDate());
      hours = this.pad(date.getUTCHours());
      mins = this.pad(date.getUTCMinutes());
      sec = this.pad(date.getUTCSeconds());
      return year + "-" + month + "-" + dates + "T" + hours + ":" + mins + ":" + sec + "Z";
    },
    pad: function(number) {
      console.log(number);
      if (number < 10) {
        return '0' + number;
      }
      return number;
    },
    setup_socket: function() {
      var _this;
      _this = this;
      this.socket = new WebSocket("ws://" + location.hostname + ":" + (+location.port + 1));
      this.socket.onopen = function() {
        return _this.socket.send('hello world and what is your name?');
      };
      this.socket.onmessage = function(event) {
        var data, date;
        console.log(event);
        data = JSON.parse(event.data);
        switch (data.type) {
          case "request":
            _this.handle_request(data.data);
            break;
          case "usage":
            _this.handle_usage(data.data);
            break;
          case "base_info":
            _this.base_info.app_name = data.name;
            _this.base_info.memory_size = data.memory_size;
            date = new Date(data.start_time.replace('GMT', ''));
            _this.base_info.start_time = _this.UTCDateString(date);
            setTimeout(function() {
              return $("time.timeago").timeago();
            }, 100);
            setInterval(function() {
              return $("time.timeago").timeago();
            }, 60000);
            break;
        }
      };
      return this.socket.onclose = function() {
        console.log('Lost connection! Maybe server is close.');
        return setTimeout(function() {
          return _this.setup_socket();
        }, 100);
      };
    },
    handle_request: function(data) {
      return this.requests_list.list.unshift(data);
    },
    handle_usage: function(data) {
      this.base_info.cpu_percent = data.cpu_usage.toFixed(2);
      this.base_info.memory_percent = (data.memory_usage / (1024 * 1024 * 10)).toFixed(2);
      this.base_info.fps = data.fps;
      this.base_info.count = data.thread_count;
      this.base_info.path = data.viewcontroller_path;
      if (this.memory_chart.getContext) {
        this.setup_chart();
        return;
      }
      this.cpu_data.datasets[0].data.push(data.cpu_usage);
      this.cpu_chart.addData([data.cpu_usage], '');
      if (this.cpu_chart.datasets[0].points.length > this.chart_max_count) {
        this.cpu_chart.removeData();
      }
      this.cpu_chart.update();
      this.memory_data.datasets[0].data.push(data.memory_usage);
      this.memory_chart.addData([data.memory_usage >> 20], '');
      if (this.memory_chart.datasets[0].points.length > this.chart_max_count) {
        this.memory_chart.removeData();
      }
      this.memory_chart.update();
      this.fps_data.datasets[0].data.push(data.fps);
      this.fps_chart.addData([data.fps], '');
      if (this.fps_chart.datasets[0].points.length > this.chart_max_count) {
        this.fps_chart.removeData();
      }
      return this.fps_chart.update();
    },
    setup_chart: function() {
      var cpu_ctx, fps_ctx, memory_ctx, option;
      $.each($('canvas'), function() {
        var el;
        el = $(this);
        return el.attr({
          "width": el.parent().width(),
          "height": 200
        });
      });
      option = {
        pointDot: false
      };
      cpu_ctx = $("#cpu_chart").get(0).getContext("2d");
      this.cpu_chart = new Chart(cpu_ctx).Line(this.cpu_data, {
        scaleLabel: "<%=value%>%",
        pointDot: false
      });
      memory_ctx = $("#memory_chart").get(0).getContext("2d");
      this.memory_chart = new Chart(memory_ctx).Line(this.memory_data, {
        scaleLabel: "<%=value%>MB",
        pointDot: false
      });
      fps_ctx = $("#fps_chart").get(0).getContext("2d");
      return this.fps_chart = new Chart(fps_ctx).Line(this.fps_data, option);
    },
    event_bind: function() {
      $('.nav-tabs a').click(function(e) {
        e.preventDefault();
        return $(this).tab('show');
      });
      return $(window).bind('beforeunload', function(e) {
        var message;
        message = false;
        if (true) {
          message = "Are you sure to leave? make sure you backup the test data.";
          e.returnValue = message;
        } else {
          return;
        }
        return message;
      });
    },
    chart_max_count: 150,
    cpu_data: {
      labels: [],
      datasets: [
        {
          fillColor: "rgba(151,187,205,0.7)",
          strokeColor: "rgba(151,187,205,1)",
          data: []
        }
      ]
    },
    memory_data: {
      labels: [],
      datasets: [
        {
          fillColor: "rgba(216,165,159,0.7)",
          strokeColor: "rgba(216,165,159,1)",
          data: []
        }
      ]
    },
    fps_data: {
      labels: [],
      datasets: [
        {
          fillColor: "rgba(216,204,134,0.7)",
          strokeColor: "rgba(216,204,134,1)",
          data: []
        }
      ]
    }
  };

  Chart.defaults.global = {
    animation: true,
    animationSteps: 60,
    animationEasing: "easeOutQuart",
    showScale: true,
    scaleOverride: false,
    scaleSteps: null,
    scaleStepWidth: null,
    scaleStartValue: null,
    scaleLineColor: "rgba(0,0,0,.1)",
    scaleLineWidth: 1,
    scaleShowLabels: true,
    scaleLabel: "<%=value%>",
    scaleIntegersOnly: false,
    scaleBeginAtZero: false,
    scaleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
    scaleFontSize: 12,
    scaleFontStyle: "normal",
    scaleFontColor: "#666",
    responsive: true,
    maintainAspectRatio: true,
    showTooltips: false,
    customTooltips: false,
    tooltipEvents: ["mousemove", "touchstart", "touchmove"],
    tooltipFillColor: "rgba(0,0,0,0.8)",
    tooltipFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
    tooltipFontSize: 14,
    tooltipFontStyle: "normal",
    tooltipFontColor: "#fff",
    tooltipTitleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",
    tooltipTitleFontSize: 14,
    tooltipTitleFontStyle: "bold",
    tooltipTitleFontColor: "#fff",
    tooltipYPadding: 6,
    tooltipXPadding: 6,
    tooltipCaretSize: 8,
    tooltipCornerRadius: 6,
    tooltipXOffset: 10,
    tooltipTemplate: "",
    multiTooltipTemplate: "",
    onAnimationProgress: null,
    onAnimationComplete: null
  };

  $(function() {
    return Application.init();
  });

}).call(this);
