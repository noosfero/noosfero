function display_error_message(language) {
  if (!language) {
    var language = ((navigator.language) ? navigator.language : navigator.userLanguage).replace('-', '_');
  }
  element = $(language);
  if (!element) {
    element = $('en');
  }
  $$('.message').each(function(item) { item.hide() });
  element.show();
}

