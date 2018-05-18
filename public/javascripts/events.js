$(document).ready(function() {
  $('#agenda').on('ajax:send', 'a.events-by-date, .xhr-links a', function() {
    $('#events-of-the-day').addClass('loading')
    $('.calendar-day').removeClass('selected')

    if ($(this).hasClass('events-by-date')) {
      $(this).closest('.calendar-day').addClass('selected')
    }
  }).on('ajax:success', 'a.events-by-date, .xhr-links a', function(evt, data) {
    // Replace the html in the next tick,
    // otherwise ajax:complete will not be called
    setTimeout(function() {
      $('#events-of-the-day').html(data)
      $('#agenda .xhr-links a').attr('data-remote', true)
    })
  }).on('ajax:complete', 'a.events-by-date, .xhr-links a', function(evt, data) {
    $('#events-of-the-day').removeClass('loading')
  })

  $('.event-invitations').on('click', '.invitations-container', function() {
    $(this).prev('.invitations-modal-link').click()
  })

  $('.event-invitations').on('click', '.invitation-response', function() {
    $(this).closest('.invitations-container').find('.menu-toggle').click()
    return false
  })

})

function invite_decision(button, checkbox) {
  $(checkbox).attr('checked',  true)
  save_invitation_decision(button)
  $('.noosfero-dropdown-menu').hide('slow')
  return false
}

function save_invitation_decision(button) {
  var $ = jQuery;
  var $button = $(button);
  var form = $button.parents("form.invitation-form");
  var container = $button.parents('div.event-invitations')
  $.post(form.attr("action"), form.serialize(), function(data) {

    if(data.render_target != null) {
      container.html(data.html)
    } else {
      form.find('.invitation-decision-checkbox').attr('checked', false)
      display_notice(data.msg)
    }
  }, 'json');
}
