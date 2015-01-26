/**
 * Etherpad Lite plug-in for TinyMCE version 3.x
 * @author     Daniel Tygel
 * @version    $Rev: 1.0 $
 * @package    etherpadlite
 * @link https://github.com/dtygel/tinymce-etherpadlite-embed
 * EtherPad plugin for TinyMCE
 * AFFERO LICENSE
 */

(function() {
  var supportedLanguages = ['en', 'pt']
  if (supportedLanguages.indexOf(tinymce.settings.language) >= 0)
    tinymce.PluginManager.requireLangPack('etherpadlite');

	tinymce.create('tinymce.plugins.EtherPadLitePlugin', {
		init : function(ed, url) {
			var t = this;

			t.editor = ed;

			//If the person who activated the plugin didn't put a Pad Server URL, the plugin will be disabled
			if (!ed.getParam("plugin_etherpadlite_padServerUrl") || ed.getParam("plugin_etherpadlite_padServerUrl")=="") {
				return null;
			}

			var padUrl = ed.getParam("plugin_etherpadlite_padServerUrl");
			var padPrefix = (ed.getParam("plugin_etherpadlite_padNamesPrefix"))
				? ed.getParam("plugin_etherpadlite_padNamesPrefix")
				: "";
			var padWidth = (ed.getParam("plugin_etherpadlite_padWidth"))
				? ed.getParam("plugin_etherpadlite_padWidth")
				: "100%";
			var padHeight = (ed.getParam("plugin_etherpadlite_padHeight"))
				? ed.getParam("plugin_etherpadlite_padHeight")
				: "400";

			ed.addCommand('mceEtherPadLite', function() {
    	    	var padName = padPrefix + '.' + randomPadName();
				var iframe = "<iframe name='embed_readwrite' src='" + padUrl + padName + "?showControls=true&showChat=true&&alwaysShowChat=true&lang=pt&showLineNumbers=true&useMonospaceFont=false' width='" + padWidth + "' height='" + padHeight + "'></iframe>";
				ed.execCommand('mceInsertContent', false, iframe);
			});

			ed.addButton('etherpadlite', {title : 'etherpadlite.desc', cmd : 'mceEtherPadLite', image : url + '/img/etherpadlite.gif'});
		},

		getInfo : function() {
			return {
				longname : 'Insert a collaborative text with Etherpad Lite',
				author : 'Daniel Tygel',
				authorurl : 'http://cirandas.net/dtygel',
				infourl : 'https://github.com/dtygel/tinymce-etherpadlite-embed',
				version : tinymce.majorVersion + "." + tinymce.minorVersion
			};
		}
	});

	function randomPadName() {
		var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
		var string_length = 10;
		var randomstring = '';
		for (var i = 0; i < string_length; i++) {
			var rnum = Math.floor(Math.random() * chars.length);
			randomstring += chars.substring(rnum, rnum + 1);
		}
		return randomstring;
	}


	// Register plugin
	tinymce.PluginManager.add('etherpadlite', tinymce.plugins.EtherPadLitePlugin);
})();
