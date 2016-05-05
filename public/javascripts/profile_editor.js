(function($){
  'use strict';

  function show_or_hide_privacy_radio_buttons(hide_options) {
    var public_community = $(".public-community-button").parent();
    var private_community = $(".private-community-button").parent();
    if (hide_options) {
      $(".private-community-button").selected();
      public_community.hide();
      private_community.hide();

    } else {
      public_community.show();
      private_community.show();
    }
  }

  $(document).ready(function(){
    var profile_secret = $(".profile-secret-box");
    show_or_hide_privacy_radio_buttons(profile_secret.is(":checked"));
    profile_secret.change(function(){
      show_or_hide_privacy_radio_buttons(this.checked);
    });

  });

 $("#profile_data_closed_false").click(function(){
  $("#requires_email_option").prop("checked",false);
  $("#requires_email_option").hide();
 });

 $("#profile_data_closed_true").click(function(){
  $("#requires_email_option").show();
 });

})(jQuery);
