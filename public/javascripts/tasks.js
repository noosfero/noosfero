(function($) {

  $("input.task_accept_radio").click(function(){
    task_id = this.getAttribute("task_id");
    var accept_container = $('#on-accept-information-' + task_id);
    var reject_container = $('#on-reject-information-' + task_id);

    accept_container.show('fast');
    reject_container.hide('fast');
    $('#on-skip-information-'   + task_id).hide('fast');
    $('#custom-field-information-' + task_id).show('fast');
    reject_container.find('input, select').prop('disabled', true);
    accept_container.find('input, select').prop('disabled', false);
  })

  $("input.task_reject_radio").click(function(){
    task_id = this.getAttribute("task_id");
    var accept_container = $('#on-accept-information-' + task_id);
    var reject_container = $('#on-reject-information-' + task_id);

    accept_container.hide('fast');
    reject_container.show('fast');
    $('#on-skip-information-'   + task_id).hide('fast');
    $('#custom-field-information-' + task_id).show('fast');
    reject_container.find('input, select').prop('disabled', false);
    accept_container.find('input, select').prop('disabled', true);
  })

  $("input.task_skip_radio").click(function(){
    task_id = this.getAttribute("task_id");
    $('#on-accept-information-' + task_id).hide('fast');
    $('#on-reject-information-' + task_id).hide('fast');
    $('#on-skip-information-'   + task_id).show('fast');
    $('#custom-field-information-' + task_id).hide('fast');
  })

  // There is probably an elegant way to do this...
  $('#up-set-all-tasks-to').selectedIndex = 0;
  $('#down-set-all-tasks-to').selectedIndex = 0;

  $('#down-set-all-tasks-to').change(function(){
    value = $('#down-set-all-tasks-to').selected().val();
    up = $('#up-set-all-tasks-to')
    up.attr('value', value).change();
  })

  $('#up-set-all-tasks-to').change(function(){
    value = $('#up-set-all-tasks-to').selected().val();
    down = $('#down-set-all-tasks-to')
    down.attr('value', value);
    $('.task_'+value+'_radio').each( function(){
      if(!this.disabled){
        $(this).attr('checked', 'checked').click();
      }
    })
  })

  $('.task_title').css('margin-right', $('.task_decisions').width()+'px');
  $('.task_title').css('margin-left', $('.task_arrow').width()+'px');

  //Autocomplete tasks by type
  $('#filter-text-autocomplete').autocomplete({
    source:function(request,response){
      $.ajax({
        url:document.location.pathname+'/search_tasks',
        dataType:'json',
        data:{
          filter_text:request.term,
          filter_type:jQuery('#filter-type').val()
        },
        success:response
      })
    },
    minLength:2
  });

})(jQuery)

function change_task_responsible(el) {
  jQuery.post($(el).data('url'), {task_id: $(el).data('task'),
                    responsible_id: $(el).val(),
                    old_responsible_id: $(el).data('old-responsible')}, function(data) {
    if (data.success) {
      $(el).effect("highlight");
      $(el).data('old-responsible', data.new_responsible.id);
    } else {
      $(el).effect("highlight", {color: 'red'});
    }
    if (data.notice) {
      display_notice(data.notice);
    }
  });
}

