if ( navigator.appVersion.indexOf("MSIE 5") > -1 ) {
  if ( document.cookie.indexOf("better-browser-promotion=done") == -1 ) {
    var bbp = $("better-browser-promotion")
    bbp.style.display = 'block';
    bbp.innerHTML += '<a href="javascript:void(bbp.style.display=\'none\')" class="button icon-close"><span>X</span></a>'
    // remember to show only one time per session:
    document.cookie = "better-browser-promotion=done";
  }
}
