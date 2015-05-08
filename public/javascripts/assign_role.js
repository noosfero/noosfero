(function($){
  'use strict';

  function toggle_assignment_method() {
    if (this.value != "roles") {
      $('.assign_by_roles').hide();
      $('.assign_by_members').show();
    } else {
      $('.assign_by_members').hide();
      $('.assign_by_roles').show();
    }
  }

  $(document).ready(function() {
    $('.assign_by_roles').hide();
    // Event triggers
    $('.assign_role_by').click(toggle_assignment_method);
  });
})(jQuery);
