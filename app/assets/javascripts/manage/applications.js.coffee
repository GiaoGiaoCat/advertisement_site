# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  chartColours = ['#f7cb38', '#62aeef', '#72c380', '#5a8022', '#d8605f', '#6f7a8a', '#2c7282']

  #check if element exist and draw chart
  if $("#app_contents_data_holder").length > 0
    $ ->
      d1 = []; d2 = []; d3 = []
      ad_views = []; ad_clicks = []; ad_installs = []

      if $("#app_contents_data").data("ad-views")
        ad_views = $("#app_contents_data").data("ad-views")
      i = 0
      while i < ad_views.length
        d1.push [new Date(ad_views[i]["day"]).getTime(), ad_views[i]["count"]]
        i++

      if $("#app_contents_data").data("ad-clicks")
        ad_clicks = $("#app_contents_data").data("ad-clicks")
      i = 0
      while i < ad_clicks.length
        d2.push [new Date(ad_clicks[i]["day"]).getTime(), ad_clicks[i]["count"]]
        i++

      if $("#app_contents_data").data("ad-installs")
        ad_installs = $("#app_contents_data").data("ad-installs")
      i = 0
      while i < ad_installs.length
        d3.push [new Date(ad_installs[i]["day"]).getTime(), ad_installs[i]["count"]]
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

      plot = $.plot($("#app_contents_data_holder"), [
        label: "展示次数"
        data: d1
        lines:
          fillColor: "#FBEAB3"
        points:
          fillColor: "#fff"
      ,
        label: "点击次数"
        data: d2
        lines:
          fillColor: "#D3E2EE"
        points:
          fillColor: "#fff"
      ,
        label: "安装次数"
        data: d3
        lines:
          fillColor: "#BBF7C6"
        points:
          fillColor: "#fff"
      ], options)

