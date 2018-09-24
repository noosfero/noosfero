function loadMoreComments() {
  var commentList = $('#article-comments-list');
  if (commentList.length > 0) {
    var pageId = commentList.data('page');
    var profile = commentList.data('profile');
    var nextCommentPage = commentList.data('comment-page') + 1;

    $.get('/' + profile + '/' + pageId + '/view_more_comments', {
      comment_page: nextCommentPage,
      id: pageId,
      dataType: 'json'
    })
    .done(function() {
      commentList.data('comment-page', nextCommentPage);
      $(window).bind('scroll', bindScroll);
    });
  }
}

function bindScroll() {
  var loadingPoint = $(document).height() - 300;
  if ($(window).scrollTop() + $(window).height() > loadingPoint) {
    $(window).unbind('scroll');
    loadMoreComments();
  }
}
$(window).scroll(bindScroll);
