(function($) {
  $(window).bind('userDataLoaded', function(event, data) {
    if (data.login || $('meta[name="profile.allow_unauthenticated_comments"]').length > 0) {
      $('.post-comment-button, .page-comment-form, .comment-footer, .display-comment-form').livequery(function() {
        $(this).show();
      });
    }
  });
})(jQuery);
