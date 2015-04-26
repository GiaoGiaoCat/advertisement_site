// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require jquery-ui

// Important plugins put in all pages
//= require bootstrap/bootstrap
//= require conditionizr.min
//= require plugins/core/nicescroll/jquery.nicescroll.min
//= require plugins/core/jrespond/jRespond.min
//= require jquery.genyxAdmin

// Form plugins
//= require plugins/forms/uniform/jquery.uniform.min
//= require plugins/forms/datepicker/bootstrap-datepicker

// Table plugins
//= require plugins/tables/datatables/jquery.dataTables.min

// Charts plugins
//= require plugins/charts/flot/jquery.flot
//= require plugins/charts/flot/jquery.flot.pie
//= require plugins/charts/flot/jquery.flot.resize
//= require plugins/charts/flot/jquery.flot.tooltip.min
//= require plugins/charts/flot/jquery.flot.orderBars
//= require plugins/charts/flot/jquery.flot.time.min
//= require plugins/charts/flot/date

// Easy pie chart
//= require plugins/charts/pie-chart/jquery.easy-pie-chart

// Init plugins
//= require app
//= require pages/domready

//= require_tree .
//= require turbolinks


$(document).on('page:fetch', function() {
  $(".loading-indicator").show();
});
$(document).on('page:change', function() {
  $(".loading-indicator").hide();
});
$(document).ready(function() {
      // Store variables
      var accordion_head = $('.accordion > li > a'),
        accordion_body = $('.accordion li > .sub-menu');
      // Open the first tab on load
      accordion_head.first().addClass('active').next().slideDown('normal');
      // Click function
      accordion_head.on('click', function(event) {
        // Disable header links
        event.preventDefault();
        // Show and hide the tabs on click
        if ($(this).attr('class') != 'active'){
          accordion_body.slideUp('normal');
          $(this).next().stop(true,true).slideToggle('normal');
          accordion_head.removeClass('active');
          $(this).addClass('active');
        }
      });
    });
$(document).ready(
function() {
    $('.checkall').click(function () {
     var $checks = $(this).parents('table').find("tbody").find("span")
     var $checkinput = $(this).parents('table').find("tbody").find(":checkbox")
     var sign = $(this).parent("span").attr("class")
     if (sign)
        {
          $checks.addClass("checked");
          $checkinput.prop("checked", true)
        }
        else
        {
           $checks.removeClass("checked");
          $checkinput.prop("checked", false)
        }
    });
  });

$(document).ready(
function() {
    $("#select_all").click(function () {
     var $form = $(this).parent(".form-search")
     var $forms = $(this).parent("form")
     var $checkinput = $form.find(":checkbox")
     var $input = $form.children(":checkbox")
     var $checks = $(this).parent("form").children('span')
     var sign = $(this).parent("span").attr("class")
     if (sign)
        {
          $checks.addClass("checked");
          $checkinput.prop("checked", true)
        }
        else
        {
           $checks.removeClass("checked");
          $checkinput.prop("checked", false)
        }
    });
  });
var post_infer_data=function() {
    infer = $("#account_bill_adv_content").val()
       start = $("#account_bill_info_start_date").val()
       end = $("#account_bill_info_end_date").val()
      if (infer && start && end){
      $form = $(this)

       date = {begin: start, end: end, id: infer}
      $.ajax({
        type: "get",
        url: "/manage/adv_contents/get_data",
        data: {begin: $("#account_bill_info_start_date").val(), end: $("#account_bill_info_end_date").val(), id: $("#account_bill_adv_content").val()},
        beforeSend: function () {
          $("#ajax-loader").show();
        }
      });
    }
      return false;
 };
$(document).ready(function() {
  $("#account_bill_adv_content").change(post_infer_data);
});
$(document).ready(function() {
  $("#account_bill_info_end_date").change(post_infer_data);
});
$(document).ready(function() {
  $("#account_bill_info_start_date").change(post_infer_data);
});
