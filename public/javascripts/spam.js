function removeTaskBox(button, url, task_box_id, msg) {
  var $ = jQuery;
  if (msg && !confirm(msg)) {
    return;
  }
  button = $(button);
  button.addClass('task-button-loading');
  $.post(url, function (data) {
    if (data.ok) {
      $('#' + task_box_id).slideUp();
    } else {
      button.removeClass('task-button-loading');
      button.addClass('task-button-failure');
    }
  });
}

function toggleDetails(link, msg_hide, msg_show) {
  var $ = jQuery;
  $(link).toggleClass('icon-up icon-down');
  details = $(link).closest('.task_box').find('.suggest-article-details');
  if (details.css('display') == 'none') {
    link.innerHTML = msg_hide;
  } else {
    link.innerHTML = msg_show;
  }
  details.slideToggle();
}
