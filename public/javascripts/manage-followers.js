$('#profile-type-filter').live('change', function() {
  var filter_type = $(this).val();
  $(".profile-list").addClass("fetching");
  $.get(window.location.pathname, {filter: filter_type}, function(data) {
    $(".main-content").html(data);
  }).fail(function(data) {
    $(".profile-list").removeClass("fetching");
  });
});
