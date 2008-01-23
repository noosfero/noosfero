
var amul = document.getElementById( "assets_menu_ul" );
amul.h = 56;
amul.minSize = 56;
amul.maxSize = amul.getElementsByTagName("li").length * 19;
window.amul = amul;

amul.onmouseover = function () {
  clearTimeout( this.timeoutClose );
  if ( this.h < this.maxSize ) {
    this.h += 10;
    this.style.height = this.h +"px";
    this.timeoutOpen = setTimeout( "window.amul.onmouseover()", 33 );
  } else {
    this.h = this.maxSize;
    this.style.height = this.h +"px";
  }
}

amul.onmouseout = function ( doIt ) {
  clearTimeout( this.timeoutOpen );
  if ( doIt ) {
    if ( this.h > this.minSize ) {
      this.h -= 10;
      this.style.height = this.h +"px";
      this.timeoutClose = setTimeout( "window.amul.onmouseout(true)", 33 );
    } else {
      this.h = this.minSize;
      this.style.height = this.h +"px";
    }
  } else {
    // Work arround IE bug
    this.timeoutClose = setTimeout( "window.amul.onmouseout(true)", 200 );
  }
}

