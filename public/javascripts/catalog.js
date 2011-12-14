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

jQuery('#product-list .product .expand-box').hover(hover, hover).click(function () {
  this.clicked = !this.clicked;
  click(this);
  jQuery.each(jQuery(this).siblings('.expand-box'), function(index, value) { value.clicked = false; click(value); });

  return false;
});

jQuery(document).click(function() {
  jQuery.each(jQuery('#product-list .product .expand-box'), function(index, value) { value.clicked = false; click(value); });
});

var rows = {};
jQuery('#product-list .product').each(function (index, element) {
  obj = rows[jQuery(element).offset().top] || {};

  obj.heights = obj.heights || [];
  obj.elements = obj.elements || [];
  obj.heights.push(jQuery(element).height());
  obj.elements.push(element);

  rows[jQuery(element).offset().top] = obj;
});

jQuery.each(rows, function(top, obj) {
  maxWidth = Array.max(obj.heights);
  jQuery(obj.elements).height(maxWidth);
});

