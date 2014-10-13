TinyMCE Etherpad-lite Plug-in
=============================

Button to insert a textpad of etherpad-lite into TinyMCE



Installation
============
* Extract the zip to the TinyMCE plug-ins folder.
* Add etherpad-lite to the plug-ins configuration.
* Add etherpad-lite to the theme_advanced_buttons_n configuration.
* Add configuration parameters of the plugin (see the explanations below)

Parameters
=============

* plugin_etherpadlite_padServerUrl (Default: "")
The URL of the EtherPad Lite server. The plugin won't work without a defined server

* plugin_etherpadlite_padNamesPrefix (Default: "")
The prefix that will be added automatically to the pad that will be created. It's important to think of a specific prefix (like for example the url of your website), so that the pads will be unique. The names of the created pads will be numbered like this: padNamesPrefix1, padNamesPrefix2, etc. Each time one user clicks at "insert pad", a new number will be generated, ordered.

* plugin_etherpadlite_padWidth (Default: 100%)
The width of the pad that will be inserted

* plugin_etherpadlite_padHeight (Default: 400px)
The height of the pad that will be inserted

Simple usage example
================

tinyMCE.init({
	mode : "textareas",
	theme : "advanced",
	plugins : "etherpadlite",
	theme_advanced_buttons2 : "bold,italic,underline,strikethrough,separator,bullist,numlist,separator,justifyleft,justifycenter,justifyright,justifyfull,separator,link,unlink,image,table,etherpadlite,separator,cleanup",
	content_css : "css/content.css",

	// Parameters for etherpadlite Plugin:
	plugin_etherpadlite_padServerUrl: "http://pad.textb.org/p/", 
	plugin_etherpadlite_padNamesPrefix : "mypads-", 
});


NOTE
========

Here is an example of an existing pad server: 
http://pad.textb.org/p/
