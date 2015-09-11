(function($) {
  "use strict";

  function set_members_sort() {
    var profile_members_url = $("#profile_url").val();

    $("#sort-members, #sort-admins").on("change", function() {
      var sort_value = this.value;
      var role = this.id;
      role = role.replace("sort-", '');
      var actual_page_content = $(".profile-list-"+role);

      $.get(profile_members_url, {sort: sort_value}, function(response) {
        var html_response = $(response);

        actual_page_content.html(html_response.find(".profile-list-"+role).html());
      });
    });
  }

  $(document).ready(function() {
    set_members_sort();
  });
}) (jQuery);
