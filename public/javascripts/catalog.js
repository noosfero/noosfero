(function($) {

$('#product-list .product .expand-box').hover(hover, hover).live('click', function () {
  this.clicked = !this.clicked;
  click(this);
  $.each($(this).siblings('.expand-box'), function(index, value) { value.clicked = false; click(value); });

  return false;
});

$(document).live('click', function() {
  $.each($('#product-list .product .expand-box'), function(index, value) { value.clicked = false; click(value); });
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

function open() {
  if (this.clicked) return;
  jQuery(this).addClass('open');
}

function close() {
  if (this.clicked) return;
  jQuery(this).removeClass('open');
}

function click(e) {
  jQuery(e).toggleClass('open', e.clicked);
  jQuery(e).children('div').toggle(e.clicked).css({left: jQuery(e).position().left-180, top: jQuery(e).position().top-10});
}

function hover() {
  jQuery(this).toggleClass('hover');
}
