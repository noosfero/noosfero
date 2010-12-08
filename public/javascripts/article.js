(function($) {
  $("#lead-button").click(function(){
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $('#article-lead').slideToggle();
    return false;
  })
  $("#body-button").click(function(){
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $('#article-body-field').slideToggle();
    return false;
  })
})(jQuery)
