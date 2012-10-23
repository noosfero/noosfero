/**
 * jQuery sound plugin (no flash)
 * 
 * port of script.aculo.us' sound.js (http://script.aculo.us), based on code by Jules Gravinese (http://www.webveteran.com/) 
 * 
 * Copyright (c) 2007 Jörn Zaefferer (http://bassistance.de) 
 * 
 * Licensed under the MIT license:
 *   http://www.opensource.org/licenses/mit-license.php
 *   
 * $Id$
 */

/**
 * API Documentation
 * 
 * // play a sound from the url
 * $.sound.play(url)
 * 
 * // play a sound from the url, on a track, stopping any sound already running on that track
 * $.sound.play(url, {
 *   track: "track1"
 * });
 * 
 * // increase the timeout to four seconds before removing the sound object from the dom for longer sounds
 * $.sound.play(url, {
 *   timeout: 4000
 * });
 * 
 * // disable playing sounds
 * $.sound.enabled = false;
 * 
 * // enable playing sounds
 * $.sound.enabled = true
 */

(function($) {
	
$.sound = {
  tracks: {},
  enabled: true,
  template: function(src) {
  	return '<embed style="height:0" loop="false" src="' + src + '" autostart="true" hidden="true"/>';
  },
  play: function(url, options){
    if (!this.enabled)
		return;
    var settings = $.extend({
	  url: url,
	  timeout: 2000
    }, options);
	
	if (settings.track) {
		if (this.tracks[settings.track]) {
			var current = this.tracks[settings.track];
			current.Stop && current.Stop();
			current.remove();  
		}
	}
	
	var element = $.browser.msie
	  	? $('<bgsound/>').attr({
	        src: settings.url,
			loop: 1,
			autostart: true
	      })
	  	: $(this.template(settings.url));
    element.appendTo("body");
	
	if (settings.track) {
		this.tracks[settings.track] = element;
	}
	
	setTimeout(function() {
		element.remove();
	}, 2000)
  }
};

})(jQuery);
