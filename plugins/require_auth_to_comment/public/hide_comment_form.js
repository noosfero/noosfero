(function($) {
  $(window).bind('userDataLoaded', function(event, data) {
    if (data.login || $('meta[name="profile.allow_unauthenticated_comments"]').length > 0) {
      $('.post-comment-button').show();
      $('#page-comment-form').show();
      $('.comment-footer').show();
    }
  });
})(jQuery);
