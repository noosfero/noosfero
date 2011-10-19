jQuery(function($) {
  $('.report-abuse-action').live('click', function() {
    if($(this).attr('href')){
      $.fn.colorbox({
        href: $(this).attr('href'),
        innerHeight: '300px',
        innerWidth: '445px'
      });
    }
    return false;
  });

  $('#report-abuse-submit-button').click(function(){
    loading_for_button(this);
  });
});

