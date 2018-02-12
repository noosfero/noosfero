$(document).ready(function() {
  function enableDownloadButton() {
    var content = $('.failed-csv-content').val()
    content = encodeURIComponent(content)
    var downloadUri = 'data:text/plain;charset=utf-8,' + content
    $('a.download-failed-csv').attr('href', downloadUri)
    $('a.download-failed-csv').attr('disabled', false)
  }

  function tooltipFor(el) {
    var rowNumber = $(el).parent('tr.row-entry').data('row-number')
    var colNumber = $(el).data('col-number')
    return $('.tooltip-error.for-' + rowNumber + '-' + colNumber)
  }

  $('.import-report table').on('mouseenter', 'td.error', function(evt) {
    var tooltip = tooltipFor(this).show()
    var offset = $('.import-report').offset()
    var table = $('.import-report table')

    var posX = evt.clientX - offset.left
    var posY = evt.clientY - offset.top
    var scrollOffsetX = table.scrollLeft() + $(document).scrollLeft()
    var scrollOffsetY = table.scrollTop() + $(document).scrollTop()
    tooltip.css({
      top: posY + (tooltip.outerHeight() / 3) + scrollOffsetY,
      left: posX - (tooltip.outerWidth() / 2) + scrollOffsetX
    })
  })

  $('.import-report table').on('mouseleave', 'td.error', function(evt) {
    tooltipFor(this).hide()
  })

  enableDownloadButton()
})
