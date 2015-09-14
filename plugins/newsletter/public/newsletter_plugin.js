jQuery(function($) {
  $(".newsletter-toggle-link").live('click', function(){
    element_id = this.getAttribute('element_id');
    toggle_link = this;
    $(element_id).slideToggle(400, function() {
      if ($(toggle_link).find('.ui-icon').hasClass('ui-icon-triangle-1-s'))
        $(toggle_link).find('.ui-icon')
          .removeClass('ui-icon-triangle-1-s')
          .addClass('ui-icon-triangle-1-n');
      else
        $(toggle_link).find('.ui-icon')
          .removeClass('ui-icon-triangle-1-n')
          .addClass('ui-icon-triangle-1-s');
    });
    return false;
  });

  $('#file_recipients').change(function(){
    $('#newsletter-file-options input').enable();
  });
});
