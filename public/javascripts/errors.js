function display_error_message(language) {
  if (!language) {
    var language = ((navigator.language) ? navigator.language : navigator.userLanguage).replace('-', '_');
  }
  var $element = $('#' + language);
  if ($element.size() == 0) {
    $element = $('#' + language.replace(/_.*$/, ''));
  }
  if ($element.size() == 0) {
    element = $('en');
  }
  $('.message').hide();
  $element.show();
  $('title').html($element.find('h1').html());
}

