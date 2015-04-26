jQuery ->
  $('#sortDataTable').dataTable
    "bPaginate": false


  chartColours = ['#f7cb38', '#62aeef', '#72c380', '#5a8022', '#d8605f', '#6f7a8a', '#2c7282']

  #check if element exist and draw chart
  if $("#adv_contents_data_holder").length > 0
    $ ->
      d1 = []; d2 = []; d3 = []; d4 = []
      ad_views = []; ad_clicks = []; ad_installs = []; ad_reports = []

      if $("#adv_contents_data").data("ad-views")
        ad_views = $("#adv_contents_data").data("ad-views")
      i = 0
      while i < ad_views.length
        d1.push [new Date(ad_views[i]["day"]).getTime(), ad_views[i]["count"]]
        i++

      if $("#adv_contents_data").data("ad-clicks")
        ad_clicks = $("#adv_contents_data").data("ad-clicks")
      i = 0
      while i < ad_clicks.length
        d2.push [new Date(ad_clicks[i]["day"]).getTime(), ad_clicks[i]["count"]]
        i++

      if $("#adv_contents_data").data("ad-installs")
        ad_installs = $("#adv_contents_data").data("ad-installs")
      i = 0
      while i < ad_installs.length
        d3.push [new Date(ad_installs[i]["day"]).getTime(), ad_installs[i]["count"]]
        i++

      if $("#adv_contents_data").data("ad-reports")
        ad_reports = $("#adv_contents_data").data("ad-reports")
      i = 0
      while i < ad_reports.length
        d4.push [new Date(ad_reports[i]["day"]).getTime(), ad_reports[i]["count"]]
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
          min: 1

        xaxis:
          mode: "time"
          minTickSize: tickSize
          timeformat: tformat
          min: chartMinDate
          max: chartMaxDate

      plot = $.plot($("#adv_contents_data_holder"), [
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
      ,
        label: "激活次数"
        data: d4
        lines:
          fillColor: "#A3E93C"
        points:
          fillColor: "#fff"
      ], options)
