// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function noosfero_init() {
  focus_first_field();
  detect_internet_explorer();
}

/* Adds a class to "msie" to the body element if a Microsoft browser is
 * detected. This is needed to workaround several of their limitations.
 */
function detect_internet_explorer() {
  if ( navigator.appName.indexOf("Microsoft") > -1 ) {
    document.body.className += " msie";
  }
}

/* If applicable, find the first field in which the user can type and move the
 * keyboard focus to it.
 */
function focus_first_field() {
  form = document.forms[0];
  if (form == undefined) {
    return;
  }

  for (var i = 0; i < form.elements.length; i++) {
    field = form.elements[i];
    if (field.type == 'text' || field.type == 'textarea') {
      field.focus();
      return;
    }
  }
}
