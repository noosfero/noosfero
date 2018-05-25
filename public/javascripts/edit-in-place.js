$(document).ready(function() {

  $('.edit-in-place a.edit-image').on('click', function() {
    var form = $(this).siblings('form')
    var file_input = form.find('.image-input')

    file_input.click()

    $(file_input).on('change', function() {
      submit_remote_form(form)
    })
  })


})

function edit_in_place(element) {
  var form = $(element).closest('form.edit-in-place')
  var container = $(element).closest('.edit-in-place-container')
  var input = container.find('div.edit-in-place-field')
  var actual = container.find('.edit-in-place-info')

  actual.hide('slow')
  input.show('slow')

  $(form).submit(function(e){
    e.preventDefault();
  });

  input.find('input').on('change', function(e) {
    e.stopPropagation()
    edit_in_place_submit(form, container)
    return false
  })

  return false
}

function edit_in_place_image(element) {
  var form = $(element).closest('form.edit-in-place')
  var container = $(element).closest('.edit-in-place-container')
  var input = container.find('div.edit-in-place-field input[type=file]')
  var actual = container.find('.edit-in-place-info')

  $(form).submit(function(e){
    e.preventDefault();
  });

  input.click()

  input.on('change', function(e) {
    cropImage(this)
    $('#confirm-crop-image').live('click', function() {
      edit_in_place_submit_image(form, container)
    })
    return false
  })

  return false
}

function edit_in_place_submit(form, field) {
  var $ = jQuery;

  $.post(form.attr("action"), form.serialize(), function(data) {

    if(data.response == 'success') {
      field.replaceWith(data.html)
    } else {
      if(data.msg != null) {
         display_notice(data.msg);
      }
    }
  }, 'json')
}

function edit_in_place_submit_image(form, field) {

  var formData = new FormData(form[0]);

  $.ajax({
    url: form.attr("action"),
    type: 'POST',
    data: formData,
    async: false,
    cache: false,
    contentType: false,
    processData: false,
    complete: function(data) {
      var response = JSON.parse(data.responseText)
      if(response.response == 'success') {
        field.replaceWith(response.html)
      } else {
        if(response.msg != null) {
           display_notice(response.msg);
        }
      }
    }
  })
}
