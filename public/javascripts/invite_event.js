jQuery(function($) {

  $('#invite-select-all').change(function() {
    $('#token-input-search-people-to-invite').attr('disabled', this.checked)
    $('#token-input-search-people-to-invite').toggleClass('disabled')
    $('.token-input-token').toggle('slow')
  })

  $(".task-actions .invite-decision-yes").click(function(){

    $(this).closest('.task-description').find('.custom-field-information')
           .find('.task-invite-event-decision-yes').attr('checked', true)

    submit_decision_with_details(this)

    return false
  });

  $(".task-actions .invite-decision-no").click(function(){
    $(this).closest('.task-description').find('.custom-field-information')
           .find('.task-invite-event-decision-no').click()

    $(this).closest('.task-description').find(".task-decisions")
           .children(".task-accept-radio").attr("checked", "checked");

    $(this).closest("form").submit();
    return false
  });

  $(".task-actions .invite-decision-maybe").click(function(){
    $(this).closest('.task-description').find('.custom-field-information')
           .find('.task-invite-event-decision-maybe').attr('checked', true)

    submit_decision_with_details(this)

    return false
  });

  function submit_decision_with_details(button) {
    var accept_details = $(button).closest('.task-description').find('.task-view-details')

    if(accept_details.length != 0 && accept_details.css('display') == 'none') {
      accept_details.show('slow')
    } else {
      $(button).closest('.task-description').find(".task-decisions")
             .children(".task-accept-radio").attr("checked", "checked");
      $(button).closest("form").submit();
    }
  }
})
