jQuery('.display-comment-form').unbind();
jQuery('.display-comment-form').click(function(){
  var $button = jQuery(this);
  toggleBox($button.parents('.post_comment_box'));
  jQuery($button).hide();
  $button.closest('.page-comment-form').find('input[type="text"]:visible,textarea').first().focus();
  return false;
});

jQuery('#cancel-comment').die();
jQuery('#cancel-comment').live("click", function(){
  var $button = jQuery(this);
  toggleBox($button.parents('.post_comment_box'));
  show_display_comment_button();
  var page_comment_form = $button.parents('.page-comment-form');
  page_comment_form.find('.errorExplanation').remove();
  return false;
});

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
  var form = $button.parents("form");
  var post_comment_box = $button.parents('.post_comment_box');
  var comment_div = $button.parents('.comments');
  var page_comment_form = $button.parents('.page-comment-form');
  $button.addClass('comment-button-loading');
  $.post(form.attr("action"), form.serialize(), function(data) {

    if(data.render_target == null) {
      //Comment for approval
      form.find("input[type='text']").add('textarea').each(function() {
        this.value = '';
      });
      page_comment_form.find('.errorExplanation').remove();
    } else if(data.render_target == 'form') {
      //Comment with errors
      $.scrollTo(page_comment_form);
      page_comment_form.html(data.html);
      $('.display-comment-form').hide();
    } else if($('#' + data.render_target).size() > 0) {
      //Comment of reply
      $('#'+ data.render_target).replaceWith(data.html);
      $('#' + data.render_target).effect("highlight", {}, 3000);
      noosfero.modal.close();
      increment_comment_count(comment_div);
    } else {
      //New comment of article
      comment_div.find('.article-comments-list').append(data.html);

      form.find("input[type='text']").add('textarea').each(function() {
        this.value = '';
      });

      page_comment_form.find('.errorExplanation').remove();
      noosfero.modal.close();
      increment_comment_count(comment_div);
    }

    if(jQuery('#recaptcha_response_field').val()){
      Recaptcha.reload();
    }

    if(data.msg != null) {
       display_notice(data.msg);
    }
    close_loading();
    toggleBox($button.closest('.post_comment_box'));
    show_display_comment_button();
    $button.removeClass('comment-button-loading');
    $button.enable();
  }, 'json');
}

function increment_comment_count(comment_div) {
  comment_div.find('.comment-count').add('#article-header .comment-count').each(function() {
    var count = parseInt(jQuery(this).html());
    update_comment_count(jQuery(this), count + 1);
  });
}

function show_display_comment_button() {
  if(jQuery('.post_comment_box.opened').length==0)
    jQuery('.display-comment-form').show();
}
