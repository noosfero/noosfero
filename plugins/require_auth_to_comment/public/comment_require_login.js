(function($) {
  $(window).bind('userDataLoaded', function(event, data) {
    if (!data.login && $('meta[name="profile.allow_unauthenticated_comments"]').length <= 0) {
      $('.display-comment-form').unbind();
      $('.display-comment-form').addClass('require-login-popup');
    }
  });
})(jQuery);
