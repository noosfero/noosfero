jQuery('.display-comment-form').click(function(){
  toggleBox('.post_comment_box');
  jQuery('.display-comment-form').hide();
  jQuery('form.comment_form input').first().focus();
  return false;
});

jQuery('#cancel-comment').click(function(){
  toggleBox('.post_comment_box');
  jQuery('.display-comment-form').show();
  return false
})

function toggleBox(div_selector){
  div = jQuery(div_selector);
  if(div.hasClass('opened')) {
    div.removeClass('opened');
    div.addClass('closed');
  } else {
    div.removeClass('closed');
    div.addClass('opened');
  }
}
