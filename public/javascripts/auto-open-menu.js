
function setAutoOpenMenu( menu ) {

  var mul = menu.getElementsByTagName("ul")[0];
  if ( !mul ) return false;

  mul.h = mul.clientHeight; // remember the current height to a faster animation
  mul.minSize = mul.clientHeight;
  var vli = mul.getElementsByTagName("li");
  mul.paddingBottom = parseInt( menu.className.replace( /.*AOM_paddingBottom_([^\s]+).*/, "$1" ) );
  mul.maxSize = ( vli.length * ( vli[1].offsetTop - vli[0].offsetTop ) );

  window["autoOpenMenu-"+menu.id] = menu;
  menu.mul = mul;

  if ( mul.minSize == 1 ) {
    // Work arround bug for IE - ie sux - ie sux - ie sux - ie sux -ie sux -ie sux -ie sux - ie sux!!!
    mul.h = 12;
    setTimeout('m = window[\'autoOpenMenu-'+menu.id+'\']; m.onmouseout()', 10);
  }

  menu.isIE = ( navigator.appName.indexOf("Microsoft") > -1 );

  menu.onmouseover = function () {
    clearTimeout( this.timeoutClose );
    var mul = this.mul;
    if ( mul.paddingBottom ) mul.parentNode.style.paddingBottom = mul.paddingBottom +"px";
    if ( mul.h < mul.maxSize ) {
      mul.h += 10;
      mul.style.height = mul.h +"px";
      this.timeoutOpen = setTimeout( "window['autoOpenMenu-"+this.id+"'].onmouseover()", 33 );
    } else {
      mul.h = mul.maxSize;
      mul.style.height = mul.h +"px";
    }
  }

  menu.onmouseout = function ( doIt ) {
    clearTimeout( this.timeoutOpen );
    var mul = this.mul;
    if ( doIt ) {
      if ( mul.h > mul.minSize ) {
        mul.h -= 10;
        if ( mul.h < 0 ) mul.h = 0;
        if ( this.isIE ) if ( mul.h < 1 ) mul.h = 1;
        mul.style.height = mul.h +"px";
        this.timeoutClose = setTimeout( "window['autoOpenMenu-"+this.id+"'].onmouseout(true)", 33 );
      } else {
        mul.h = mul.minSize;
        mul.style.height = mul.h +"px";
        if ( mul.paddingBottom ) mul.parentNode.style.paddingBottom = "0px";
      }
    } else {
      // Work arround IE bug
      this.timeoutClose = setTimeout( "window['autoOpenMenu-"+this.id+"'].onmouseout(true)", 200 );
    }
  }

}
