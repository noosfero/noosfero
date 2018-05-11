function loadMoreComments() {
  let commentList = $('#article-comments-list');
  let pageId = commentList.data('page');
  let profile = commentList.data('profile');
  let nextCommentPage = commentList.data('comment-page') + 1;

  $.get(`/${profile}/${pageId}/view_more_comments`, {
    comment_page: nextCommentPage,
    id: pageId, 
    dataType: 'json'
  })
  .done(function() {
    commentList.data('comment-page', nextCommentPage);
    $(window).bind('scroll', bindScroll);
  });
}

function bindScroll() {
  let loadingPoint = $(document).height() - 300;
  if ($(window).scrollTop() + $(window).height() > loadingPoint) {
    $(window).unbind('scroll');
    loadMoreComments();
  }
}
$(window).scroll(bindScroll);
