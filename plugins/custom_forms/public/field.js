var fixHelperSortable = function(e, tr) {
  tr.children().each(function() {
    jQuery(this).width(jQuery(this).width());
  });
  return tr;
};

var updatePosition = function(e, ui) {
  var tag = ui.item[0].tagName.toLowerCase();
  var count = ui.item.prevAll(tag).eq(0).find('input').filter(function() {return /_position/.test(this.id); }).val();
  count = count ? ++count : 0;

  ui.item.find('input').filter(function() {return /_position/.test(this.id); }).eq(0).val(count);

  for (i = 0; i < ui.item.nextAll(tag).length; i++) {
    count++;
    ui.item.nextAll(tag).eq(i).find('input').filter(function() {return /_position/.test(this.id); }).val(count);
  }
}

jQuery('tbody.field-list').sortable({
  helper: fixHelperSortable,
  update: updatePosition
});

jQuery("ul.field-list").sortable({
  placeholder: 'ui-state-highlight',
  axis: 'y',
  opacity: 0.8,
  cursor: 'move',
  tolerance: 'pointer',
  forcePlaceholderSize: true,
  update: updatePosition
});

jQuery("ul.field-list li").disableSelection();

var customFormsPlugin = {
  removeFieldBox: function (button, confirmMsg) {
    if (confirm(confirmMsg)) {
      fb = jQuery(button).closest('.field-box');
      jQuery('input.destroy-field', fb).val(1);
      jQuery(fb).slideUp(600, 'linear');
    }
  },

  removeAlternative: function (button, confirmMsg) {
    if (confirm(confirmMsg)) {
      alt = jQuery(button).closest('tr.alternative');
      jQuery('input.destroy-field', alt).val(1);
      alt.fadeOut(500, function() {
        customFormsPlugin.checkHeaderDisplay(jQuery(button).closest('table'));
      });
    }
  },

  addFields: function (button, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    content = content.replace(regexp, new_id);

    if(association == 'alternatives') {
      jQuery(content).appendTo(jQuery(button).closest('tfoot').next('tbody.field-list')).hide().slideDown();
      jQuery(button).closest('table').find('tr:first').show();
      jQuery(button).closest('tfoot').next('tbody.field-list').sortable({ helper: fixHelperSortable, update: updatePosition});
    } else {
      jQuery('<li>').append(jQuery(content)).appendTo(jQuery(button).parent().prev('ul.field-list')).hide().slideDown();
    }

    jQuery('input').filter(function () { return new RegExp(new_id + "_position", "g").test(this.id); }).val(new_id);
  },

  checkHeaderDisplay: function(table) {
    trs =jQuery('tr:visible', table);
    if (trs.length <= 2) {
      trs[0].style.display = 'none';
    } else {
      trs[0].style.display = 'table-row';
    }
  }
}
