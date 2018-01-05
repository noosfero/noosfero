noosfero.modal = {

  watchClass: function() {
    jQuery(function($) {
      $(document).delegate('.modal-toggle', 'click', function() {
        var url = $(this).attr('href')
        noosfero.modal.url(url)

        return false;
      });

      $('.modal-close').on('click', function() {
        $(this).closest("#cboxClose").click();
        return false;
      });

    });
  },

  url: function (url, options) {
    $.colorbox({
      href:       url,
      maxWidth:   $(window).width()-50,
      height:     $(window).height()-50,
      open:       true,
      close:      'Cancel',
      class:      'modal',
      onComplete: function(bt) {
        var opt = {}, maxH = $(window).height()-50;
        if ($('#cboxLoadedContent *:first').height() > maxH) opt.height = maxH;
        $.colorbox.resize(opt);
      }
    });
  },

  inline: function(href, options) {
    $("#noosfero-modal-inner").html($(href).html());
    $("#noosfero-modal").fadeIn().css("display", "flex");
  },

  html: function(html, options) {
    options = jQuery.extend({
      html: html,
    }, options);

    jQuery.colorbox(options);
  },

  close: function() {
    jQuery.colorbox.close();
  },

};

noosfero.modal.watchClass();

/**** New modal ****/
//$(function() {
$( document ).ready(function() {
  $("body").on('click', '.open-modal', function(event) {
    event.preventDefault();
    $.get($(this).attr('href'), function(data) {
      $("#noosfero-modal-inner").html(data);
      $("#noosfero-modal").fadeIn().css("display", "flex");
    });
  });

  $("#close-modal").click(function() {
    $("#noosfero-modal").fadeOut();
  });

  $(".modal-close").live('click', function() {
    $("#noosfero-modal").fadeOut();
  });

  $(window).click(function(event) {
    if($(event.target).is("#noosfero-modal")) {
      $("#noosfero-modal").fadeOut(500);
    }
  });
});
