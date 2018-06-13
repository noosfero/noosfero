(function() {

function fetchStates(countryCode) {
  $.get('/national_regions/states?country_code=' + countryCode, function(data) {
    replaceOptions('#profile_data_city', [])
    replaceOptions('#profile_data_state', data.states)
  })
}

function fetchCities(stateCode) {
  $.get('/national_regions/cities?state_code=' + stateCode, function(data) {
    replaceOptions('#profile_data_city', data.cities)
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
  $('#profile_data_country').on('change', function() {
    fetchStates($(this).val())
  })

  $('#profile_data_state').on('change', function() {
    fetchCities($(this).val())
  })
})

})()
