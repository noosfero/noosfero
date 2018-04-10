function add_comment_reply_form(comment_id) {
  var comment = $('#comment-' + comment_id)
  var container = comment.children('.reply-comment-form')
  var form = container.find('form.comment_form')
  container.removeClass('hidden')
  if(form.length == 0) {
    form = $('#page-comment-form form.comment_form').clone().first()
    container.append(form)

    $('#page-comment-form .errorExplanation').remove()
    form.find('script').remove()
    form.find('.comment-recaptcha div').remove()
    form.find('#comment-field').val('')
    form.find('#comment_id').val('')
    form.find('#comment_reply_of_id').val(comment_id)
    form.find('#comment-captcha').attr('id', 'comment-' + comment_id
                                                        + '-captcha')
    form.find('#comment-field').focus()
    if(typeof(renderCaptcha) === typeof(Function))
      renderCaptcha(form.find('.comment-recaptcha')[0])

    return false
  }

  if(container.hasClass('closed')) {
    container.removeClass('closed')
    container.addClass('opened')
    container.find('.comment_form input[type=text]:visible:first').focus()
  }
  return false
}

function update_comment_count(element, new_count) {
  var $ = jQuery;
  var content = '';
  var parent_element = element.parent();

  write_out = parent_element.find('.comment-count-write-out');

  element.html(new_count);

  if(new_count == 0) {
    content = NO_COMMENT_YET;
    parent_element.addClass("no-comments-yet");
  } else if(new_count == 1) {
    parent_element.removeClass("no-comments-yet");
    content = ONE_COMMENT;
  } else {
    content = new_count + ' ' + COMMENT_PLURAL;
  }

  if(write_out){
    write_out.html(content);
  }
}

function send_comment_action(link) {
  var comment_id = link.closest('.comment-actions').data('comment-id')
  var message = link.data('message')
  var url = link.data('url')

  if ((message && confirm(message)) || !message) {
    $.post(url, function(data) {
      if (data.ok) {
        var comment = $('#comment-' + comment_id);
        var replies = comment.find('.comment-replies li.comment-container');
        var comments_removed = 1;

        comment.slideUp(400, function() {
          if(link.hasClass('remove-children')) {
            comments_removed += replies.length
          } else {
            replies.appendTo('#article-comments-list')
          }
          $('.comment-count-write-out').each(function() {
            var count = parseInt($(this).text());
            update_comment_count($(this), count - comments_removed);
          });
          $(this).remove();
        });
      }
    });
  }
}

$(document).ready(function() {
  $('a.comment-remove').live('click', function() {
    var comment_id = $(this).closest('.comment-actions').data('comment-id')
    var message = $(this).data('message')
    var url = $(this).data('url')
    send_comment_action(comment_id, message, url)
  })

  $('a.comment-action').live('click', function() {
    send_comment_action($(this))
  })

  $(".comment-item .reply-comment-link").live('click', function(){
     var comment_id = $(this).data('comment-id')
     add_comment_reply_form(comment_id)
  })

  $("#comments_list").on("click", "#cancel-comment", function(){
    var container = $(this).parents(".reply-comment-form")
    container.find("textarea").val("")
    container.addClass('hidden')
    return false
  })
})

function show_comment_reply_form(element){
  var activityId = $(element).data("activity-id");
  var tabAction = $(element).data("tab-action");
  hide_and_show(['#profile-' + tabAction + '-message-response-' + activityId], ['#profile-' + tabAction + '-reply-' + activityId, '#profile-' + tabAction + '-reply-form-' + activityId]);
  jQuery('#reply_content_' + tabAction + '_' + activityId).val('');
  jQuery('#reply_content_' + tabAction + '_' + activityId).focus();
  return false;
}

function show_scrap_reply_form(element){
  var scrapId = $(element).data("scrap-id");
  hide_and_show(['#profile-wall-message-response-' + scrapId], ['#profile-wall-reply-' + scrapId, '#profile-wall-reply-form-' + scrapId]);
  jQuery('#reply_content_' + scrapId).val('');
  jQuery('#reply_content_' + scrapId).focus();
  return false;
}

function fill_placeholder(element){
  if(element.value == ''){
    element.value = element.title;
    element.style.color = '#ccc';
  };
  element.style.backgroundImage = 'none';
}

function clear_placeholder(element){
  if(element.value == element.title){
    element.value = '';
    element.style.color = '#000';
  };
}