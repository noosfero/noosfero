(function($) {
  // Pagination
  $('#manage-profiles').on('click', '.pagination a', function () {
    $.ajax({
      url: this.href,
      beforeSend: function(){$('#manage-profiles .results').addClass('fetching')},
      complete: function() {$('#manage-profiles .results').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });

  // Actions
  $('#manage-profiles').on('click', '.action', function () {
    if(confirm($(this).data('confirm'))) {
      $.ajax({
        url: this.href,
        method: $(this).data('method') || 'get',
        dataType: 'script',
        success: function(data){
          if(data)
            display_notice(JSON.parse(data));
         },
         error: function(xhr, textStatus, message){
           display_notice(message);
         }
      });
      $('#manage-profiles').submit();
    }
    return false;
  });

  // Sorting and Views
  $('#manage-profiles select').live('change', function(){
    $('#manage-profiles').submit();
  });

  // Form Ajax submission
  $('#manage-profiles').submit(function () {
    $.ajax({
      url: this.action,
      data: $(this).serialize(),
      beforeSend: function(){$('#manage-profiles .results').addClass('fetching')},
      complete: function() {$('#manage-profiles .results').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });
})(jQuery);
