(function($){
  'use strict';

  function toggle_invitation_method() {
    if (+(this.value) === 1) {
      $('.invite_by_email').hide();
      $('.invite_by_name').show();
    } else {
      $('.invite_by_name').hide();
      $('.invite_by_email').show();
    }
  }

  function manage_members_moderation() {
    var checked = $('#profile_data_allow_members_to_invite').is(':checked');

    if (checked) {
      $('.invite_friends_only').show();
    } else {
      $('.invite_friends_only').hide();
    }
  }

  function hide_invite_friend_login_password() {
    $('#invite-friends-login-password').hide();
  }

  function show_invite_friend_login_password() {
    if (this.value === 'hotmail') {
      $('#hotmail_username_tip').show();
    } else {
      $('#hotmail_username_tip').hide();
    }

    $('#invite-friends-login-password').show();
    $('#login').focus();
  }

  $(document).ready(function() {
    $('.invite_by_email').hide();
    manage_members_moderation();

    // Event triggers
    $('.invite_friend_by').click(toggle_invitation_method);

    $("#import_from_manual").click(hide_invite_friend_login_password);

    $('.invite_by_this_email').click(show_invite_friend_login_password);

    $('#profile_data_allow_members_to_invite').click(manage_members_moderation);
  });
})(jQuery);
