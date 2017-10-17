$(document).ready(function() {
  // Disables the input fields of all templates
  $('.action-cms-new form, .action-cms-edit form').submit(function() {
    $('#article-custom-field-templates').find(":input")
                                        .prop("disabled", true);
    return true
  })

  // Adds a datepicker for every date field once, using the template as base
  $('body').on('focus', '.custom-datepicker', function() {
    if (!$(this).hasClass('hasDatepicker')) {
      var baseScript = $('#article-custom-field-templates script').text();
      baseScript = baseScript.replace(/jQuery\(.*\)/, '$(this)')
      eval(baseScript)
    }
  })
})


$('#custom-field-name').on('keydown', function(e) {
  var ENTER_KEY = 13
  if (e.which == ENTER_KEY) {
    addCustomField()
    return false
  }
})

$('#article-custom-fields-wrapper #show-opts-link').on('click', function() {
  $(this).fadeOut(function() {
    $('#article-custom-fields-opts').fadeIn()
  })
  return false
})

$('#article-custom-fields-opts #hide-opts-link').on('click', function() {
  $('#article-custom-fields-opts').fadeOut(function() {
    $('#article-custom-fields-wrapper #show-opts-link').fadeIn()
    $('#article-custom-fields-opts #custom-field-name').removeClass('custom-field-error')
    $('#article-custom-fields-opts #custom-field-name').val("")
  })
  return false
})

$('#article-custom-fields-opts #add-field-btn').on('click', function() {
  addCustomField()
  return false
})

$('#article-custom-fields').on('click', '.remove-article-btn', function() {
  $(this).closest('div.article-custom-field-wrapper').remove()
  return false
})

function addCustomField() {
  var name = $('#article-custom-fields-opts #custom-field-name').val().trim()
  if ((name === '') || !isCustomFieldNameValid(name)) {
    $('#article-custom-fields-opts #custom-field-name').addClass('custom-field-error')
  } else {
    var template_name = $('#article-custom-fields-opts #custom-field-type').val()
    var template = $('#article-custom-field-templates #' + template_name).html()
    template = template.replace(/FIELD-NAME-TEMPLATE/gi, name)

    $('#article-custom-fields').append(template)
    $('#article-custom-fields-opts #custom-field-name').val('')
    $('#article-custom-fields-opts #custom-field-name').removeClass('custom-field-error')
  }
}

function isCustomFieldNameValid(name) {
  var names = $('#article-custom-fields .custom-field-input .custom-field-name').toArray().map(function(e){
    return e.value.toLowerCase()
  })
  return (names.indexOf(name.toLowerCase()) >= 0) ? false : true
}

