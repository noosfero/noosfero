
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

if ( document.cookie.indexOf("mouseHelpTurnOn=") > -1 ) {
  if ( document.cookie.indexOf("mouseHelpTurnOn=true") > -1 ) {
    mouseHelpOnOff();
  }
} else {
  var date = new Date();
  date.setTime( date.getTime() + ( 60*24*60*60*1000 ) );
  var expires = "; expires=" + date.toGMTString();
  document.cookie = "mouseHelpTurnOn=false" + expires +"; path=/";
  if ( confirm("Olá, você gostaria de ativar o modo de ajuda automática do Noosfero?") ) { 
    mouseHelpOnOff();
  } else {
    alert("Caso precise, basta clicar no icone de ajuda no canto superior direito da página.")
  }
}
