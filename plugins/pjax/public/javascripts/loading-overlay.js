if (typeof loading_overlay === 'undefined') {

// block user actions while making a post. Also indicate the network transaction
loading_overlay = {

  show: function (selector) {
    var element = jQuery(selector);
    var overlay = jQuery('<div>', {
      class: 'loading-overlay',
      css: {
        width: element.outerWidth(),
        height: element.outerHeight(),
        left: element.position().left,
        top: element.position().top,
        marginLeft: parseFloat(element.css('margin-left')),
        marginTop: parseFloat(element.css('margin-top')),
        marginRight: parseFloat(element.css('margin-right')),
        marginBottom: parseFloat(element.css('margin-bottom')),
      },
    }).appendTo(element).get(0);

    overlay.dest = element;
    element.loading_overlay = overlay;
  },

  hide: function (selector) {
    var element = jQuery(selector);
    var overlay = element.find('.loading-overlay');
    overlay.remove();
  },

};

}
