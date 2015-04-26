# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->

  #define chart clolors ( you maybe add more colors if you want or flot will add it automatic )
  chartColours = ["#62aeef", "#5a8022", "#72c380", "#6f7a8a", "#f7cb38", "#5a8022", "#2c7282"]

  #check if element exist and draw chart
  if $("#count_holder").length
    $ ->
      d1 = []; d2 = []; array_total = []
      array_total = $("#data_holder").data("total-orders")
      i = 0

      while i < array_total.length
        d1.push [new Date(array_total[i]["day"]).getTime(), array_total[i]["count"]]
        i++
      array_completed = $("#data_holder").data("completed-orders")
      i = 0

      while i < array_completed.length
        d2.push [new Date(array_completed[i]["day"]).getTime(), array_completed[i]["count"]]
        i++
      chartMinDate = d1[0][0] #first day
      chartMaxDate = d1[d1.length - 1][0] #last day
      tickSize = [1, "day"]
      tformat = "%d/%m/%y"

      #graph options
      options =
        grid:
          show: true
          aboveData: true
          color: "#3f3f3f"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor: null
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 100

        series:
          lines:
            show: true
            fill: true
            lineWidth: 2
            steps: false

          points:
            show: true
            radius: 2.8
            symbol: "circle"
            lineWidth: 2.5

        legend:
          position: "ne"
          margin: [0, -25]
          noColumns: 0
          labelBoxBorderColor: null
          labelFormatter: (label, series) ->

            # just add some space to labes
            label + "&nbsp;&nbsp;"

          width: 40
          height: 1

        colors: chartColours
        shadowSize: 0
        tooltip: true #activate tooltip
        tooltipOpts:
          content: "%s: %y.0"
          xDateFormat: "%d/%m"
          shifts:
            x: -30
            y: -50

          defaultTheme: false

        yaxis:
          min: 0

        xaxis:
          mode: "time"
          minTickSize: tickSize
          timeformat: tformat
          min: chartMinDate
          max: chartMaxDate

      plot = $.plot($("#count_holder"), [
        label: "下单数量"
        data: d1
        lines:
          fillColor: "#f3faff"

        points:
          fillColor: "#fff"
      ,
        label: "成单数量"
        data: d2
        lines:
          fillColor: "#cbf9be"

        points:
          fillColor: "#fff"
      ], options)


  #check if element exist and draw chart
  if $("#money_holder").length
    $ ->
      d1 = []; d2 = []; array_total = []
      array_total = $("#data_holder").data("total-orders")
      i = 0

      while i < array_total.length
        d1.push [new Date(array_total[i]["day"]).getTime(), array_total[i]["total"]]
        i++
      array_completed = $("#data_holder").data("completed-orders")
      i = 0

      while i < array_completed.length
        d2.push [new Date(array_completed[i]["day"]).getTime(), array_completed[i]["total"]]
        i++
      chartMinDate = d1[0][0] #first day
      chartMaxDate = d1[d1.length - 1][0] #last day
      tickSize = [1, "day"]
      tformat = "%d/%m/%y"

      #graph options
      options =
        grid:
          show: true
          aboveData: true
          color: "#3f3f3f"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor: null
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 100

        series:
          lines:
            show: true
            fill: true
            lineWidth: 2
            steps: false

          points:
            show: true
            radius: 2.8
            symbol: "circle"
            lineWidth: 2.5

        legend:
          position: "ne"
          margin: [0, -25]
          noColumns: 0
          labelBoxBorderColor: null
          labelFormatter: (label, series) ->

            # just add some space to labes
            label + "&nbsp;&nbsp;"

          width: 40
          height: 1

        colors: chartColours
        shadowSize: 0
        tooltip: true #activate tooltip
        tooltipOpts:
          content: "%s : %y.2 元",
          shifts:
            x: -30
            y: -50

          defaultTheme: false

        yaxis:
          min: 0

        xaxis:
          mode: "time"
          minTickSize: tickSize
          timeformat: tformat
          min: chartMinDate
          max: chartMaxDate

      plot = $.plot($("#money_holder"), [
        label: "预计收入"
        data: d1
        lines:
          fillColor: "#f3faff"

        points:
          fillColor: "#fff"
      ,
        label: "实际收入"
        data: d2
        lines:
          fillColor: "#cbf9be"

        points:
          fillColor: "#fff"
      ], options)


  # channel devices charts
  if $("#channel_devices_holder").length > 0
    $ ->
      d1 = []; array_total = []
      array_total = $("#data_holder").data("channel-devices")
      i = 0

      while i < array_total.length
        d1.push [new Date(array_total[i]["day"]).getTime(), array_total[i]["count"]]
        i++

      chartMinDate = d1[0][0] #first day
      chartMaxDate = d1[d1.length - 1][0] #last day
      tickSize = [1, "day"]
      tformat = "%y/%m/%d"

      #graph options
      options =
        grid:
          show: true
          aboveData: true
          color: "#3f3f3f"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor: null
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 100

        series:
          lines:
            show: true
            fill: true
            lineWidth: 2
            steps: false

          points:
            show: true
            radius: 2.8
            symbol: "circle"
            lineWidth: 2.5

        legend:
          position: "ne"
          margin: [0, -25]
          noColumns: 0
          labelBoxBorderColor: null
          labelFormatter: (label, series) ->

            # just add some space to labes
            label + "&nbsp;&nbsp;"

          width: 40
          height: 1

        colors: chartColours
        shadowSize: 0
        tooltip: true #activate tooltip
        tooltipOpts:
          content: "%s : %y",
          shifts:
            x: -30
            y: -50

          defaultTheme: false

        yaxis:
          min: 0
          tickDecimals: 0

        xaxis:
          mode: "time"
          minTickSize: tickSize
          timeformat: tformat
          min: chartMinDate
          max: chartMaxDate

      plot = $.plot($("#channel_devices_holder"), [
        label: "新增用户"
        data: d1
        lines:
          fillColor: "#f3faff"

        points:
          fillColor: "#fff"
      ], options)

  # channel orders charts
  if $("#channel_orders_holder").length > 0
    $ ->
      d1 = []; d2 = []; d3 = []; array_total = []
      array_total = $("#data_holder").data("channel-orders")
      i = 0

      while i < array_total.length
        d1.push [new Date(array_total[i]["day"]).getTime(), array_total[i]["count"]]
        i++
      array_completed = $("#data_holder").data("completed-orders")
      i = 0

      while i < array_completed.length
        d2.push [new Date(array_completed[i]["day"]).getTime(), array_completed[i]["count"]]
        i++
      array_shipped = $("#data_holder").data("shipped-orders")
      i = 0

      while i < array_shipped.length
        d3.push [new Date(array_shipped[i]["day"]).getTime(), array_shipped[i]["count"]]
        i++

      chartMinDate = d1[0][0] #first day
      chartMaxDate = d1[d1.length - 1][0] #last day
      tickSize = [1, "day"]
      tformat = "%y/%m/%d"

      #graph options
      options =
        grid:
          show: true
          aboveData: true
          color: "#3f3f3f"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor: null
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 100

        series:
          lines:
            show: true
            fill: true
            lineWidth: 2
            steps: false

          points:
            show: true
            radius: 2.8
            symbol: "circle"
            lineWidth: 2.5

        legend:
          position: "ne"
          margin: [0, -25]
          noColumns: 0
          labelBoxBorderColor: null
          labelFormatter: (label, series) ->

            # just add some space to labes
            label + "&nbsp;&nbsp;"

          width: 40
          height: 1

        colors: chartColours
        shadowSize: 0
        tooltip: true #activate tooltip
        tooltipOpts:
          content: "%s : %y",
          shifts:
            x: -30
            y: -50

          defaultTheme: false

        yaxis:
          min: 0
          tickDecimals: 0

        xaxis:
          mode: "time"
          minTickSize: tickSize
          timeformat: tformat
          min: chartMinDate
          max: chartMaxDate

      plot = $.plot($("#channel_orders_holder"), [
        label: "新增订单"
        data: d1
        lines:
          fillColor: "#f3faff"

        points:
          fillColor: "#fff"
      ,
        label: "成交订单"
        data: d2
        lines:
          fillColor: "#cbf9be"

        points:
          fillColor: "#fff"
      ,
        label: "发货订单"
        data: d3
        lines:
          fillColor: "#ddf6da"

        points:
          fillColor: "#fff"
      ], options)



  # channel devices charts
  if $("#channel_devices_holder_spreader").length > 0
    $ ->
      d1 = []; array_total = []
      array_total = $("#data_holder_spreader").data("channel-devices")
      i = 0

      while i < array_total.length
        d1.push [new Date(array_total[i]["day"]).getTime(), array_total[i]["count"]]
        i++

      chartMinDate = d1[0][0] #first day
      chartMaxDate = d1[d1.length - 1][0] #last day
      tickSize = [1, "day"]
      tformat = "%y/%m/%d"

      #graph options
      options =
        grid:
          show: true
          aboveData: true
          color: "#3f3f3f"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor: null
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 100

        series:
          lines:
            show: true
            fill: true
            lineWidth: 2
            steps: false

          points:
            show: true
            radius: 2.8
            symbol: "circle"
            lineWidth: 2.5

        legend:
          position: "ne"
          margin: [0, -25]
          noColumns: 0
          labelBoxBorderColor: null
          labelFormatter: (label, series) ->

            # just add some space to labes
            label + "&nbsp;&nbsp;"

          width: 40
          height: 1

        colors: chartColours
        shadowSize: 0
        tooltip: true #activate tooltip
        tooltipOpts:
          content: "%s : %y",
          shifts:
            x: -30
            y: -50

          defaultTheme: false

        yaxis:
          min: 0
          tickDecimals: 0

        xaxis:
          mode: "time"
          minTickSize: tickSize
          timeformat: tformat
          min: chartMinDate
          max: chartMaxDate

      plot = $.plot($("#channel_devices_holder_spreader"), [
        label: "新增用户"
        data: d1
        lines:
          fillColor: "#f3faff"

        points:
          fillColor: "#fff"
      ], options)

  # if $(".percentage").length
  #   $(".percentage").easyPieChart
  #     barColor: '#62aeef'
  #     borderColor: '#227dcb'
  #     trackColor: '#d7e8f6'
  #     scaleColor: false
  #     lineCap: 'butt'
  #     lineWidth: 20
  #     size: 80
  #     animate: 1500
