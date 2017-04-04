$(document).ready(function() {

  $('#custom-routes').on('click', 'tr a.icon-remove', function () {
    var tableRow = $(this).closest('tr')
    var routeId = $(this).data('id')
    tableRow.addClass('loading')

    $.post($(this).attr('href'), { route_id: routeId })
    .done(function(response) {
      tableRow.remove()
    }).fail(function(response) {
      tableRow.removeClass('loading')
      display_notice(response.responseJSON['msg'])
    })

    return false
  })

})
