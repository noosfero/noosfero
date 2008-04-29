// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function noosfero_init() {
  // focus_first_field(); it is moving the page view when de form is down.
}

/* If applicable, find the first field in which the user can type and move the
 * keyboard focus to it.
 *
 * ToDo: focus only inside the view box to do not roll the page.
 */
function focus_first_field() {
  form = document.forms[0];
  if (form == undefined) {
    return;
  }

  for (var i = 0; i < form.elements.length; i++) {
    field = form.elements[i];
    if (field.type == 'text' || field.type == 'textarea') {
      try {
        field.focus();
        return;
      } catch(e) { }
    }
  }
}

/* * * Convert a string to a valid login name * * */
function convToValidLogin( str ) {
  return str.toLowerCase()
            .replace( /á|à|ã|â/g, "a" )
            .replace( /é|ê/g,     "e" )
            .replace( /í/g,       "i" )
            .replace( /ó|ô|õ|ö/g, "o" )
            .replace( /ú|ũ|ü/g,   "u" )
            .replace( /ñ/g,       "n" )
            .replace( /ç/g,       "c" )
            .replace( /[^-_a-z0-9]+/g, "" )
}


/* * *  Template Box Size Help  * * */
function resizePrincipalTemplateBox() {
  var box1 = $$( "div.box-1" )[0];
  var otherBoxSum = 10;
  var i = 2;
  var b = $$( "div.box-" + i++ )[0];
  while ( b && b.nodeName ) {
    otherBoxSum += b.clientWidth;
    b = $$( "div.box-" + i++ )[0] || false;
  }
  if ( box1 )
    box1.style.width = ( $("boxes").clientWidth - otherBoxSum ) +"px"
}

if ( window.addEventListener ) {
  window.addEventListener( 'resize', resizePrincipalTemplateBox, false );
  window.addEventListener( 'load',   resizePrincipalTemplateBox, false );
}
