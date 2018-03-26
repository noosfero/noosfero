(function() {

$(document).ready(function() {
  $('form').on('keyup', '#profile_data_contact_phone, ' +
                        '#profile_data_cell_phone, ' +
                        '#profile_data_comercial_phone', function() {
    var regex = /^\d{5,15}$/
    var submitButton = $(this).closest('form').find('input[type=submit]')
    if (!regex.test($(this).val())) {
      $(this).addClass('invalid')
      submitButton.prop('disabled', true)
    } else {
      $(this).removeClass('invalid')
      submitButton.prop('disabled', false)
    }
  })
})

})()
