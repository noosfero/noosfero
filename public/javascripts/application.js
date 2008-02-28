// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function noosfero_init() {
  focus_first_field();
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
      try {
        field.focus();
        return;
      } catch(e) { }
    }
  }
}

/* * *  Template Box Size Help  * * */
function resizePrincipalTemplateBox() {
  var box1 = $$( "div.box-1" )[0];
  var otherBoxSum = 0;
  var i = 2;
  var b = $$( "div.box-" + i++ )[0];
  while ( b.nodeName ) {
    otherBoxSum += b.clientWidth;
    b = $$( "div.box-" + i++ )[0] || false;
  }
  box1.style.width = ( $("boxes").clientWidth - otherBoxSum ) +"px"
}

if ( window.addEventListener ) {
  window.addEventListener( 'resize', resizePrincipalTemplateBox, false );
  window.addEventListener( 'load',   resizePrincipalTemplateBox, false );
}
