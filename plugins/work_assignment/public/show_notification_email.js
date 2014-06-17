jQuery(function($) {
  function show_hide_token_input() {
    if($('input:checkbox[name="article_email_notification"]').attr('checked')){
      $("#email_notifications").css('display', 'inline-block');}
    else
      $("#email_notifications").css('display', 'none');
  }

  show_hide_token_input();
  //Hide / Show the text area
  $("#checkbox-0").click(show_hide_token_input);
});