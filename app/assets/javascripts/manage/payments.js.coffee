# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->

  if $("#payments_table_toolbar").length
    $("#payments_table_toolbar .change-state-btn").click ->
      state = $(this).data("state");
      $("#state").val(state);
