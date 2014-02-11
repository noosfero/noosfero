jQuery(function($) {
  $(".lead-button").live('click', function(){
    article_id = this.getAttribute("article_id");
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $(article_id).slideToggle();
    return false;
  })
});
