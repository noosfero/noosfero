function mark_comments_as_read(comments) {
  jQuery(document).ready(function($) {
    for(var i=0; i<comments.length; i++) {
      $comment = jQuery('#comment-'+comments[i]);
      $comment.find('.comment-content').first().addClass('comment-mark-read');
    }
  });
}

function toggle_comment_read(button, url, mark) {
  var $ = jQuery;
  var $button = $(button);
  $button.addClass('comment-button-loading');
  $.post(url, function(data) {
    if (data.ok) {
      var $comment = $button.closest('.article-comment');
      var $content = $comment.find('.comment-content').first();
      if(mark)
        $content.addClass('comment-mark-read');
      else
        $content.removeClass('comment-mark-read');
      $button.hide();
      $button.removeClass('comment-button-loading');
      return;
    }
  });
}

