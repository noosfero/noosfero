(function($) {

  function toggle_expandbox(element, open) {
    element.clicked = open;
    $(element).toggleClass('open', open);
  }

  $('#product-list .expand-box').live('click', function () {
    var me = this;
    $('.expand-box').each(function(index, element){
      if ( element != me ) toggle_expandbox(element, false);
    });
    toggle_expandbox(me, !me.clicked);
    return false;
  });

  $('#product-list .float-box').live('click', function () {
    return false;
  });

  $(document).click(function (event) {
     if ($(event.target).parents('.expand-box').length == 0) {
       $('#product-list .expand-box').each(function(index, element){
         toggle_expandbox(element, false);
       });
     }
  });

})(jQuery);
