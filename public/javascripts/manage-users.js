jQuery(function ($) {
  $(".export-people-field").hide();
  
  $(".export-people-list, #cancel-exportation").click(function () {
    $(".export-people-field").slideToggle();
  });
});
