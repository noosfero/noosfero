noosfero.modal = {

  el: function() {
    return jQuery('#noosferoModal')
  },
  content: function() {
    return jQuery('#noosferoModalContent')
  },

  init: function() {
    noosfero.modal.watchClass();
  },

  show: function(options) {
    noosfero.modal.el().modal(options);
    noosfero.modal.resize();
  },

  resize: function(){
    var width = $('#noosferoModalContent').children().outerWidth(true);
    if (width > 500)
      $('#noosferoModal .modal-dialog').css('width', width)
  },

  watchClass: function() {
    $(document).delegate('.modal-toggle', 'click', function() {
      var url = $(this).attr('href')
      noosfero.modal.url(url)

      return false;
    });

    $(document).delegate('.modal-close', 'click', function() {
      noosfero.modal.close();
      return false;
    });
    return false;
  },

  url: function (url, options) {
    noosfero.modal.content().empty().load(url, function() {
      noosfero.modal.resize();
    });
    noosfero.modal.show(options);
  },

  inline: function(href, options) {
    noosfero.modal.html(jQuery(href).html(), options)

    return false;
  },

  html: function(html, options) {
    noosfero.modal.content().html(html)
    noosfero.modal.show(options);
  },

  close: function(){
    noosfero.modal.el().modal('hide');
  },

};

$(function() {
  noosfero.modal.init();
})

