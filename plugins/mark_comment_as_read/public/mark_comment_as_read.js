function toggle_comment_read(button, url, mark) {
  var $ = jQuery;
  var comment = $(button).closest('.comment-item')
  var menu = $(button).closest('.noosfero-dropdown-menu')
  $.post(url, function(data) {
    if (data.ok) {
      if (mark) {
        comment.addClass('read-comment')
        menu.find('.mark-comment-read').closest('li').hide()
        menu.find('.mark-comment-not-read').closest('li').show()
      }
      else {
        comment.removeClass('read-comment')
        menu.find('.mark-comment-not-read').closest('li').first().hide()
        menu.find('.mark-comment-read').closest('li').first().show()
      }
      return;
    }
  });
}

$(document).ready(function() {

  $('.mark-comment-link').closest('li').hide()
  $('.mark-comment-link').each(function() {
    var link = $(this).first()
    if(link.data('show')) {
      link.closest('li').show()
      if(link.hasClass('mark-comment-not-read')) {
        link.closest('.comment-item').addClass('read-comment')
      }
    }
  })

})
