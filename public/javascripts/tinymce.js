
noosfero.tinymce = {

  defaultOptions: {
    theme: "modern",
    relative_urls: false,
    remove_script_host: false,
    extended_valid_elements: "applet[style|archive|codebase|code|height|width],comment,iframe[src|style|allowtransparency|frameborder|width|height|scrolling],embed[title|src|type|height|width],audio[controls|autoplay],video[controls|autoplay],source[src|type]",
    entity_encoding: 'raw',
    setup: function(editor) {
      tinymce_macros_setup(editor)
    },
  },

  init: function(_options) {
    var options = jQuery.extend({}, this.defaultOptions, _options);
    // just init. initing this is necessary to add some buttons to the toolbar
    tinymce.init(options);
//    var options = jQuery.extend({selector: '.tiny_mce_simple'}, this.defaultOptions, _options);
//    delete options['toolbar2'];
//    options['menubar'] = false;
    // just init. initing this is necessary to add some buttons to the toolbar
//    tinymce.init(options);
  },
};
