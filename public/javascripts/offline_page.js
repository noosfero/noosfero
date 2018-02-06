$(document).ready(function() {
  $('.offline-actions .button.go-back').on('click', function() {
    history.back()
    return false
  })

  $('.offline-actions .button.reload').on('click', function() {
    location.reload()
    return false
  })
})
