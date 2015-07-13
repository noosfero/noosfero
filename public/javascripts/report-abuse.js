jQuery(function($) {
  $('.report-abuse-action').live('click', function() {
    if($(this).attr('href'))
      noosfero.modal.url($(this).attr('href'));

    return false;
  });

  $('#report-abuse-submit-button').live('click', function(e) {
    e.preventDefault();
    loading_for_button(this);
    form = $(this).parents('form');
    $.post(form.attr("action"), form.serialize(), function(data) {
      data = $.parseJSON(data);
      $(this).parents('#colorbox').colorbox.close();
      if(data.ok) {
        display_notice(data.message);
      } else {
        display_notice(data.error.message);
      }
    });
  });

});

