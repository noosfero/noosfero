(function($) {

$('#product-list .product .expand-box').live('click', function () {
  $('.expand-box').each(function(index, element){ this.clicked = false; toggle_expandbox(this); });
  this.clicked = !this.clicked;
  toggle_expandbox(this);
  $.each($(this).siblings('.expand-box'), function(index, value) { value.clicked = false; toggle_expandbox(value); });

  return false;
});

$(document).live('click', function() {
  $.each($('#product-list .product .expand-box'), function(index, value) { value.clicked = false; toggle_expandbox(value); });
});

$(document).click(function (event) {
   if ($(event.target).parents('.expand-box').length == 0) {
     $('.expand-box').each(function(index, element){
       $(element).removeClass('open');
       $(element).children('div').toggle(false);
     });
   }
});

var rows = {};
$('#product-list .product').each(function (index, element) {
  obj = rows[$(element).offset().top] || {};

  obj.heights = obj.heights || [];
  obj.elements = obj.elements || [];
  obj.heights.push($(element).height());
  obj.elements.push(element);

  rows[$(element).offset().top] = obj;
});

$.each(rows, function(top, obj) {
  maxWidth = Array.max(obj.heights);
  $(obj.elements).height(maxWidth);
});

})(jQuery);

function toggle_expandbox(e) {
  jQuery(e).toggleClass('open', e.clicked);
  jQuery(e).children('div').toggle(e.clicked).css({left: jQuery(e).position().left-180, top: jQuery(e).position().top-10});
}
