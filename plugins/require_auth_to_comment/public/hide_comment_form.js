(function($) {
  $(window).bind('userDataLoaded', function(event, data) {
    if (data.login || $('meta[name="profile.allow_unauthenticated_comments"]').length > 0) {
      $('.post-comment-button').livequery(function() {
        $(this).show();
      });
      $('.page-comment-form').livequery(function() {
        $(this).show();
      });
      $('.comment-footer').livequery(function() {
        $(this).show();
      });
    }
  });
})(jQuery);
