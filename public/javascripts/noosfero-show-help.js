
function mouseHelpOnOff() {
  if ( pageHelp.info.updateBox ) {
    showMouseHelpOff()
    $("btShowHelp").className = "icon-help32on";
  } else {
    showMouseHelpOn()
    $("btShowHelp").className = "icon-help32off";
  }
  var date = new Date();
  date.setTime( date.getTime() + ( 60*24*60*60*1000 ) );
  var expires = "; expires=" + date.toGMTString();
  document.cookie = "mouseHelpTurnOn="+ pageHelp.info.updateBox + expires +"; path=/";
}

function noosferoHelpInit(confirm_msg, rejected_msg) {
  if ( document.cookie.indexOf("mouseHelpTurnOn=") > -1 ) {
    if ( document.cookie.indexOf("mouseHelpTurnOn=true") > -1 ) {
      mouseHelpOnOff();
    }
  } else {
    var date = new Date();
    date.setTime( date.getTime() + ( 60*24*60*60*1000 ) );
    var expires = "; expires=" + date.toGMTString();
    document.cookie = "mouseHelpTurnOn=false" + expires +"; path=/";
    if ( confirm(confirm_msg) ) { 
      mouseHelpOnOff();
    } else {
      alert(rejected_msg)
    }
  }
}
