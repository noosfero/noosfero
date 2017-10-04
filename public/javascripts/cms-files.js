
$(function() {
  $('#cms-files-toolbar .filters').on('change', 'select#sort-by', function() {
    var url = $(this).data('url') + '?sort_by=' + $(this).val()
    $('.cms-files table').addClass('fetching loading')
    $.ajax({
      url: url,
      type: 'get',
      dataType: 'script'
    }).always(function (data) {
      $('.cms-files table').removeClass('fetching loading')
    })
  });
});
