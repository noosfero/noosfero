jQuery('.display-comment-form').click(function(){
  toggleBox(jQuery(this).parents('.post_comment_box'));
  jQuery('.display-comment-form').hide();
  jQuery('form.comment_form input').first().focus();
  return false;
});

jQuery('#cancel-comment').live("click", function(){
  toggleBox(jQuery(this).parents('.post_comment_box'));
  jQuery('.display-comment-form').show();
  return false;
})

function toggleBox(div){
  if(div.hasClass('opened')) {
    div.removeClass('opened');
    div.addClass('closed');
  } else {
    div.removeClass('closed');
    div.addClass('opened');
  }
}

function save_comment(button) {
  var $ = jQuery;
  open_loading(DEFAULT_LOADING_MESSAGE);
  var $button = $(button);
  var form = $(button).parents("form");
  var post_comment_box = $(button).parents('.post_comment_box');
  var comment_div = $button.parents('.comments');
  $button.addClass('comment-button-loading');
  $.post(form.attr("action"), form.serialize(), function(data) {

    if(data.render_target == null) {
      //Comment for approval
      form.find("input[type='text']").add('textarea').each(function() {
        this.value = '';
      });
      form.find('.errorExplanation').remove();

    } else if(data.render_target == 'form') {
      //Comment with errors
      var page_comment_form = $(button).parents('.page-comment-form');
      $.scrollTo(page_comment_form);
      page_comment_form.html(data.html);

    } else if($('#' + data.render_target).size() > 0) {
      //Comment of reply
      $('#'+ data.render_target).replaceWith(data.html);
      $('#' + data.render_target).effect("highlight", {}, 3000);
      $.colorbox.close();

    } else {
      //New comment of article
      comment_div.find('.article-comments-list').append(data.html);

      form.find("input[type='text']").add('textarea').each(function() {
        this.value = '';
      });

      form.find('.errorExplanation').remove();
      $.colorbox.close();

    }

    comment_div.find('.comment-count').add('#article-header .comment-count').each(function() {
      var count = parseInt($(this).html());
      update_comment_count($(this), count + 1);
    });

    if(jQuery('#recaptcha_response_field').val()){
      Recaptcha.reload();
    }

    if(data.msg != null) {
       display_notice(data.msg);
    }

    close_loading();
    toggleBox($button.closest('.post_comment_box'));
    $('.display-comment-form').show();
    $button.removeClass('comment-button-loading');
    $button.enable();
  }, 'json');
}
