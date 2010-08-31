(function($) {
  $("#lead-link").click(function(){
    if($('#article-lead').css('display') == 'none')
      $('#article-lead').slideDown();
    else
      $('#article-lead').slideUp();
  })
})(jQuery)
