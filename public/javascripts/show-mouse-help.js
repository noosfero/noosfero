/*
** : : : : : :  How to use the Show Help  : : : : : :
** For each interesting page element you can put the
** attribute help. The help attribute can be any string
** text (scaped to not distroy the html) or some html id.
** The help for each element will be showed automaticaly
** when the mouse is over that. Yeah... we can turn on
** this help system calling the function showMouseHelpOn()
** and turn off calling the function showMouseHelpOff().
**
** Examples:
**
** <a href="..." help="this is a link">my link</a>
**
** <form help="#myLongHelp"> ... </form>
** <div id="myLongHelp" style="display:none">
**   This is a <b>loooong</b> help. <p/>
**   You can put <code>HTML</code> here too!
** </div>
**
** You need to put the style="display:none" on the long
** help container to it's text do not noise the web page.
**
** If the mouse pointed element do not have a help,
** each one of this parents will be visited to find
** the help. If no one has a help the help box turn
** to non visible.
*/

/*
** This script can be loaded by the page and it's iFrames,
** as in the Noofero - community network system. Some of
** this code will enable the iFrame => parent information.
*/

/*
** pageHelp has informations for this page/frame
** to not conflict with other frames.
*/
var pageHelp = {};
if ( navigator.userAgent.indexOf('MSIE') != -1 ) {
  pageHelp.isIE = ( navigator.userAgent.indexOf('Opera') == -1 )
}
// If i'm in a iFrame, get the iFrame reference:
if ( window.parent == window ) {
  pageHelp.myFrame = false;
} else {
  var randTit = "iframe"+ Math.random();
  window.frameHelpId = randTit;
  var frames = window.parent.document.getElementsByTagName("iframe");
  var f;
  for ( var i=0; f=frames[i]; i++ ) {
    if ( f.contentWindow && ( f.contentWindow.frameHelpId == randTit ) ) {
      pageHelp.myFrame = f;
    }
  }
}

/*
** pageHelp.info is a reference for a cetral help information.
** All frames will update the information here.
*/
if ( !window.parent.pageHelpInfo ) window.parent.pageHelpInfo = {};
pageHelp.info = window.parent.pageHelpInfo;
pageHelp.info.incPos = { x:20, y:20 };
pageHelp.info.myDoc = window.parent.document;

mouseBli = 0;
function getHelp( ev ) {
  var helpInfo = pageHelp.info;
  if ( helpInfo.updateBox ) {
    if ( window.event ) {
      ev = window.event;
      var el = ev.srcElement;
    } else {
      var el = ev.target;
    }
    var mX = 0;
  	var mY = 0;
    if ( ev.pageX || ev.pageY)	{
      mX = ev.pageX;
      mY = ev.pageY;
    }
    else if (ev.clientX || ev.clientY) {
      mX = ev.clientX;
      mY = ev.clientY;
      if ( pageHelp.isIE ) {
        mX += helpInfo.myDoc.body.scrollLeft;
        mY += helpInfo.myDoc.body.scrollTop;
      }
    }
    if ( pageHelp.myFrame ) {
      var fPos = pageHelp.getPos( pageHelp.myFrame );
      mX += fPos.x;
      mY += fPos.y;
    }
    var box = helpInfo.helpBox;
    helpInfo.mX = mX;
    helpInfo.mY = mY;
    if ( mX > ( helpInfo.myDoc.body.clientWidth / 1.8 ) ) {
      movePageHelpToTheLeftMouseSide()
    } else {
      movePageHelpToTheRightMouseSide()
    }
    if ( ( mY + box.clientHeight + 40 ) >
         ( helpInfo.myDoc.body.clientHeight + helpInfo.myDoc.body.scrollTop )
       ) {
      mY = helpInfo.myDoc.body.clientHeight + helpInfo.myDoc.body.scrollTop
           - box.clientHeight - 40;
    }
    if ( box ) {
      debug = mouseBli++ +" "+ el.nodeName;
      while ( el.parentNode.getAttribute && ! el.getAttribute("help") ) { el = el.parentNode }
      debug += " :: "+ el.nodeName +" "+ el.getAttribute("help");
      debug += "<br>"+ pageHelp.myFrame.src +" x:"+ mX +" y:"+ mY;
      var txt = el.getAttribute("help");
      if ( txt ) {
        box.style.display = "block";
        if ( txt != "FALSE" ) {
          if ( /^#.+/.test( txt ) ) {
            var txtEl = el.ownerDocument.getElementById( txt.replace(/#/,"") );
            if ( txtEl ) txt = txtEl.innerHTML;
          }
          box.content.innerHTML = '<p>'+ txt +'</p>'+
                                  '<br style="clear:both" />'+
                                  '<div class="help-force-clear-ieworkarroundbug"'+
                                  ' style="height:1px; overflow:hidden"></div>';
        }
      } else {
        box.style.display = "none";
      }
      box.style.left = ( mX + helpInfo.incPos.x ) +"px";
      box.style.top  = ( mY + helpInfo.incPos.y ) +"px";
    }
  }
}

pageHelp.getPos = function (obj) {
  var x = y = 0;
  if (obj.offsetParent) {
    do {
      x += obj.offsetLeft;
      y += obj.offsetTop;
    } while (obj = obj.offsetParent);
  }
  return { x:x, y:y };
}

function movePageHelpToTheLeftMouseSide() {
  clearTimeout( movePageHelpToTheRightMouseSide.timeout )
  clearTimeout( movePageHelpToTheLeftMouseSide.timeout )
  if ( pageHelp.info.incPos.x > -( pageHelp.info.helpBox.clientWidth + 20 ) ) {
    pageHelp.info.incPos.x -= 10;
    if ( ( pageHelp.info.mX + pageHelp.info.incPos.x + pageHelp.info.helpBox.clientWidth ) >
         pageHelp.info.myDoc.body.clientWidth ) {
      pageHelp.info.incPos.x =
        pageHelp.info.myDoc.body.clientWidth - pageHelp.info.helpBox.clientWidth - pageHelp.info.mX - 10;
    }
    pageHelp.info.helpBox.style.left = ( pageHelp.info.mX + pageHelp.info.incPos.x ) +"px";
    movePageHelpToTheLeftMouseSide.timeout =
    setTimeout( "movePageHelpToTheLeftMouseSide()", 20 );
  }
}

function movePageHelpToTheRightMouseSide() {
  clearTimeout( movePageHelpToTheRightMouseSide.timeout )
  clearTimeout( movePageHelpToTheLeftMouseSide.timeout )
  if ( pageHelp.info.incPos.x < 20 ) {
    pageHelp.info.incPos.x += 10;
    pageHelp.info.helpBox.style.left = ( pageHelp.info.mX + pageHelp.info.incPos.x ) +"px";
    movePageHelpToTheRightMouseSide.timeout =
    setTimeout( "movePageHelpToTheRightMouseSide()", 20 );
  }
}

if( window.addEventListener ) { // Standard
  document.body.addEventListener( "mousemove", getHelp, false );
}
if( window.attachEvent ) { // IE
  document.body.attachEvent( "onmousemove", getHelp );
}

function showMouseHelpOn() {
  pageHelp.info.helpBox = document.getElementById("helpBox");
  pageHelp.info.helpBox.content = document.getElementById("helpBoxContent");
  pageHelp.info.helpBox.setAttribute( "help", "FALSE" ); 
  pageHelp.info.updateBox = true;
  pageHelp.info.myDoc.body.style.cursor = "help";
}

function showMouseHelpOff() {
  pageHelp.info.helpBox.style.display = "none";
  pageHelp.info.updateBox = false;
  pageHelp.info.myDoc.body.style.cursor = "default";
}

