colorbox_helpers = {

  watchClass: function() {
    jQuery(function($) {
      $('.colorbox').live('click', function() {
        $.colorbox({
          href:       $(this).attr('href'),
          maxWidth:   $(window).width()-50,
          height:     $(window).height()-50,
          open:       true,
          close:      'Cancel',
          onComplete: function(bt) {
            var opt = {}, maxH = $(window).height()-50;
            if ($('#cboxLoadedContent *:first').height() > maxH) opt.height = maxH;
            $.colorbox.resize(opt);
          }
        });
        return false;
      });

      $('.colorbox-close').live('click', function() {
        $.colorbox.close();
        return false;
      });

    });
  },

  inline: function(href) {
    var href = jQuery(href);

    jQuery.colorbox({
      inline: true, href: href,
      onLoad: function(){ href.show(); },
      onCleanup: function(){ href.hide(); },
    });

    return false;
  },

};

colorbox_helpers.watchClass();

