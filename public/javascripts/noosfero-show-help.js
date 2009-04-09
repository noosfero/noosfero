
function mouseHelpOnOff() {
  if ( pageHelp.info.updateBox ) {
    showMouseHelpOff()
    $("btShowHelp").className = "icon-help32on help-on icon-help-on";
  } else {
    showMouseHelpOn()
    $("btShowHelp").className = "icon-help32off help-off icon-help-off";
  }
  var date = new Date();
  // open/close help on help button is remembed by one year:
  date.setTime( date.getTime() + ( 365*24*60*60*1000 ) );
  var expires = "; expires=" + date.toGMTString();
  document.cookie = "mouseHelpTurnOn="+ pageHelp.info.updateBox + expires +"; path=/";
}

function mouseHelpOn() {
  mouseHelpOnOff();
  new Effect.Fade( "noticeAboutHelp" );
}

function mouseHelpOff() {
  var date = new Date();
  // cancel help on question box is remembed by 5 days:
  date.setTime( date.getTime() + ( 5*24*60*60*1000 ) );
  var expires = "; expires=" + date.toGMTString();
  document.cookie = "mouseHelpTurnOn=false" + expires +"; path=/";
  new Effect.Fade( "noticeAboutHelp" );
}

if ( document.cookie.indexOf("mouseHelpTurnOn=") > -1 ) {
  if ( document.cookie.indexOf("mouseHelpTurnOn=true") > -1 ) {
    mouseHelpOnOff();
  }
}

/* O Noosfero não deve mais propor o help na entrada
else {
  new Effect.Appear( "noticeAboutHelp", {duration:2} );
}
*/
