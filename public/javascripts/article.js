(function($) {
  $("#lead-button").click(function(){
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $('#article-lead').slideToggle();
    return false;
  })
})(jQuery)
