# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('.datepicker').datepicker()

  $(".faq_goto").click ->
    height = $(this).data("height")
    $("html, body").animate
      scrollTop: height
    , "800"
    false


  #define chart clolors ( you maybe add more colors if you want or flot will add it automatic )
  chartColours = ["#62aeef", "#5a8022", "#72c380", "#6f7a8a", "#f7cb38", "#5a8022", "#2c7282"]

  #check if element exist and draw chart
  if $("#month_count_holder").length > 0
    $ ->
      d1 = []
      d2 = []
      array_total = $("#month_count_holder").data("total-orders")
      i = 0

      while i < array_total.length
        d1.push [new Date(array_total[i]["day"]).getTime(), array_total[i]["count"]]
        i++
      array_completed = $("#month_count_holder").data("completed-orders")
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

      plot = $.plot($("#month_count_holder"), [
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


  #check if element exist and draw chart stacked bars
  if $("#month_carts_holder").length > 0
    $ ->

      #some data
      d1 = []
      i = 0

      while i <= 30
        d1.push [i, parseInt(Math.random() * 30 + Math.random() * i)]
        i += 1
      d2 = []
      i = 0

      while i <= 30
        d2.push [i, parseInt(Math.random() * 30)]
        i += 1
      data = new Array()
      data.push
        label: "购物车总数"
        data: d1

      data.push
        label: "购物车转换总数"
        data: d2

      stack = 0
      bars = true
      lines = false
      steps = false
      options =
        grid:
          show: true
          aboveData: false
          color: "#3f3f3f"
          labelMargin: 5
          axisMargin: 0
          borderWidth: 0
          borderColor: null
          minBorderMargin: 5
          clickable: true
          hoverable: true
          autoHighlight: true
          mouseActiveRadius: 20

        series:
          stack: stack
          lines:
            show: lines
            fill: true
            steps: steps

          bars:
            show: bars
            barWidth: 0.5
            fill: 1

        xaxis:
          ticks: 11
          tickDecimals: 0

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
        shadowSize: 1
        tooltip: true #activate tooltip
        tooltipOpts:
          content: "数量 : %y"+"个",
          xDateFormat: "%d/%m",
          shifts:
            x: -30
            y: -50

      $.plot $("#month_carts_holder"), data, options

  #End of .cart-bars-stacked
