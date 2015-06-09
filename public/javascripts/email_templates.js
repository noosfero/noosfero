jQuery(document).ready(function($) {
  $('.template-selection select').change(function() {
    if(!$(this).val()) return;

    $.getJSON($(this).data('url'), {id: $(this).val()}, function(data) {
      $('#mailing-form #mailing_subject').val(data.parsed_subject);
      $('#mailing-form .mceEditor').val(data.parsed_body);
    });
  });
});
