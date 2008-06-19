
function setAutoOpenMenu( menu ) {

  var mul = menu.getElementsByTagName("ul")[0];
  if ( !mul ) return false;

  mul.h = mul.clientHeight; // remember the current height to a faster animation
  mul.minSize = mul.clientHeight;
  var vli = mul.getElementsByTagName("li");
  mul.paddingBottom = parseInt( menu.className.replace( /^.*AOM_paddingBottom_([^\s]+).*$/, "$1" ) );
  mul.maxSize = ( vli.length * ( vli[1].offsetTop - vli[0].offsetTop ) );
  mul.inc = 1;

  window["autoOpenMenu-"+menu.id] = menu;
  menu.mul = mul;

  if ( mul.minSize == 1 ) {
    // Work arround bug for IE - ie sux - ie sux - ie sux - ie sux -ie sux -ie sux -ie sux - ie sux!!!
    mul.h = 3;
    setTimeout('m = window[\'autoOpenMenu-'+menu.id+'\']; m.onmouseout()', 10);
  }

  menu.isIE = ( navigator.appName.indexOf("Microsoft") > -1 );

  menu.onmouseover = function () {
    clearTimeout( this.timeoutClose );
    this.className = this.className.replace( / closed/g, "" );
    if ( !/menu-opened/.test(this.className) ) { this.className += " opened" }
    var mul = this.mul;
    mul.style.display = "block";
    if ( mul.paddingBottom ) mul.parentNode.style.paddingBottom = mul.paddingBottom +"px";
    if ( mul.h < mul.maxSize ) {
      mul.h += mul.inc;
      mul.inc += 2;
      mul.style.height = mul.h +"px";
      this.timeoutOpen = setTimeout( "window['autoOpenMenu-"+this.id+"'].onmouseover()", 33 );
    } else {
      mul.h = mul.maxSize;
      mul.style.height = mul.h +"px";
      mul.inc = 1;
    }
  }

  menu.onmouseout = function ( doIt, firstDoIt ) {
    clearTimeout( this.timeoutOpen );
    var mul = this.mul;
    if ( firstDoIt ) mul.inc = 1;
    if ( doIt == true ) {
      if ( mul.h > mul.minSize ) {
        mul.h -= mul.inc++;
        if ( mul.h < 0 ) mul.h = 0;
        if ( mul.h == 0 ) mul.style.display = "none";
        if ( this.isIE ) if ( mul.h < 1 ) mul.h = 1;
        mul.style.height = mul.h +"px";
        this.timeoutClose = setTimeout( "window['autoOpenMenu-"+this.id+"'].onmouseout(true)", 33 );
      } else {
        mul.h = mul.minSize;
        mul.style.height = mul.h +"px";
        if ( mul.paddingBottom ) mul.parentNode.style.paddingBottom = "0px";
        mul.inc = 2;
        this.className = this.className.replace( / opened/g, "" );
        this.className += " closed"
     }
    } else {
      // Work arround IE bug
      this.timeoutClose = setTimeout( "window['autoOpenMenu-"+this.id+"'].onmouseout(true, true)", 200 );
    }
  }

}
