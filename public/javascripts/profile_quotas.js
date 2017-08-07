
$(document).ready(function() {
  var ENTER_KEY = 13

  $('#quota-by-profile').on('click', '.search-field .button', function() {
    reloadProfiles()
    return false;
  })

  $('#quota-by-profile').on('keypress', '.search-field input', function(e) {
    if (e.which == ENTER_KEY) {
      reloadProfiles()
      return false;
    }
  })

  $('#quota-by-profile').on('click', '.pagination a', function() {
    var url = $(this).attr('href') + '&'
    reloadProfiles(url)
    return false
  })

  $('#quota-by-profile').on('change', 'select#type-filter', function() {
    reloadProfiles()
  })

  $('#quota-by-profile .search-field input#q').autocomplete({
    minLength: 2,
    source: function(request, response) {
      $.ajax({
        url: buildUrl(),
        dataType:'json',
        success: response
      });
    }
  })

  $('#quota-by-kind').on('click', '.master-row .toggle-types', function() {
    var type = $(this).closest('.master-row').data('class')
    $('tr.nested-row.for-' + type).toggle()
    $(this).toggleClass('icon-add')
    $(this).toggleClass('icon-remove')
    return false
  })
})

function reloadProfiles(url) {
  url = buildUrl(url)
  $('.profile-list table').addClass('fetching loading')
  $.get(url).always(function (data) {
    $('.profile-list table').removeClass('fetching loading')
  })
}

function buildUrl(url) {
  var query = $('.search-field #q').val()
  var type = $('select#type-filter').val()
  if (!url) {
    url = '/admin/profile_quotas?'
  }
  return (url + 'q=' + query + '&asset=' + type)
}
