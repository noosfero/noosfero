(function() {

function fetchStates(countryCode) {
  $.get('/national_regions/states?country_code=' + countryCode, function(data) {
    replaceOptions('select.profile-city', [])
    replaceOptions('select.profile-state', data.states)
  })
}

function fetchCities(stateCode) {
  $.get('/national_regions/cities?state_code=' + stateCode, function(data) {
    replaceOptions('select.profile-city', data.cities)
  })
}

function replaceOptions(element, list) {
  $(element).find('option:not(:first-child)').remove()
  list.forEach(function(entry) {
    var option = $('<option></option>').text(entry[0]).attr('value', entry[1])
    $(element).append(option)
  })
}

$(document).ready(function() {
  $('select.profile-country').on('change', function() {
    fetchStates($(this).val())
  })

  $('select.profile-state').on('change', function() {
    fetchCities($(this).val())
  })
})

})()
