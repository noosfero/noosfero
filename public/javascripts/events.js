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
})
