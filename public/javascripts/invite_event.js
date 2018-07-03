jQuery(function($) {

  $('#invite-select-all').change(function() {
    $('#token-input-search-people-to-invite').attr('disabled', this.checked)
    $('#token-input-search-people-to-invite').toggleClass('disabled')
    $('.token-input-token').toggle('slow')
  })

  $('#set-all-tasks-to').change(function(){
    var form = $(this).closest("form")
    switch($(this).selected().val()) {
      case 'accept':
        accept_all_invite_event_tasks(form)
        break
      case 'reject':
        reject_all_invite_event_tasks(form)
        break
      case 'skip':
        skip_all_invite_event_tasks(form)
        break
    }
  })

  $('.task-box.invite_event .task-invite-event-decision-yes,' +
    '.task-box.invite_event .task-invite-event-decision-maybe,' +
    '.task-box.invite_event .task-invite-event-decision-no').click(function() {
    var task = $(this).closest(".task-box")
    task.find('.task-accept-radio').attr('checked', true)
  })

  $('.task-box.invite_event .task-invite-event-decision-unconfirmed').click(function() {
    var task = $(this).closest(".task-box")
    task.find('.task-skip-radio').attr('checked', true)
  })

  function accept_all_invite_event_tasks(form) {
    form.find('.task-box.invite_event .task-accept-radio').attr('checked', true)
    form.find('.task-box.invite_event .task-invite-event-decision-yes').attr('checked', true)
  }

  function reject_all_invite_event_tasks(form) {
    form.find('.task-box.invite_event .task-accept-radio').attr('checked', true)
    form.find('.task-box.invite_event .task-invite-event-decision-no').attr('checked', true)
  }

  function skip_all_invite_event_tasks(form) {
    form.find('.task-box.invite_event .task-skip-radio').attr('checked', true)
    form.find('.task-box.invite_event .task-invite-event-decision-unconfirmed').attr('checked', true)
  }
})
