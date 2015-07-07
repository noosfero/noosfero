$(document).ready(function() {
  var box_4_height = $(".box-4").height();

  // Make box-2(the most left one) stay align with box-4
  $(".box-2").css("margin-top", "-"+box_4_height+"px");
});
