(function($) {

  $('#set-all-tasks-to').change(function(){
    var form = $(this).closest("form")
    switch($(this).selected().val()) {
      case 'accept':
        accept_all_tasks(form)
        break
      case 'reject':
        reject_all_tasks(form)
        break
      case 'skip':
        skip_all_tasks(form)
        break
    }
  })

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

  $('.task-view-datails-link.show-details').click(function() {
    $(this).hide()
    $(this).siblings('.task-view-datails-link.hidden-details').show()
  })

  $('.task-view-datails-link.hidden-details').click(function() {
    $(this).hide()
    $(this).siblings('.task-view-datails-link.show-details').show()
  })

  $('.task-view-datails-link.hidden-details').hide()

  $('.task-accept-radio').on('click', function() {
    var task = $(this).closest('.task-box')
    task.find('.task-view-details').show('slow')
    task.find('.task-reject-explanation').hide('slow')
    task.find('.task-view-datails-link.show-details').hide()
    task.find('.task-view-datails-link.hidden-details').show()
  })

  $('.task-reject-radio').on('click', function() {
    var task = $(this).closest('.task-box')
    task.find('.task-view-details').hide('slow')
    task.find('.task-reject-explanation').show('slow')
    task.find('.task-view-datails-link.show-details').show()
    task.find('.task-view-datails-link.hidden-details').hide()
  })

  $('.task-skip-radio').on('click', function() {
    var task = $(this).closest('.task-box')
    task.find('.task-view-details').hide('slow')
    task.find('.task-reject-explanation').hide('slow')
    task.find('.task-view-datails-link.show-details').show()
    task.find('.task-view-datails-link.hidden-details').hide()
  })

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

function accept_all_tasks(form) {
  form.find('.task-reject-explanation').hide('slow')
  form.find('.task-decisions .task-accept-radio').attr('checked', true)
}

function reject_all_tasks(form) {
  form.find('.task-view-details').hide('slow')
  form.find('.task-reject-explanation').show('slow')
  form.find('.task-view-datails-link.show-details').show()
  form.find('.task-view-datails-link.hidden-details').hide()
  form.find('.task-decisions .task-reject-radio').attr('checked', true)
}

function skip_all_tasks(form) {
  form.find('.task-view-details').hide('slow')
  form.find('.task-reject-explanation').hide('slow')
  form.find('.task-view-datails-link.show-details').show()
  form.find('.task-view-datails-link.hidden-details').hide()
  form.find('.task-decisions .task-skip-radio').attr('checked', true)
}
