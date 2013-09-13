var customFormsPlugin = {
  removeFieldBox: function (button, confirmMsg) {
    if (confirm(confirmMsg)) {
      fb = jQuery(button).closest('.field-box');
      jQuery('input.destroy-field', fb).val(1);
      jQuery('> div', fb).slideUp({easing:'linear', complete:function(){fb.slideUp({easing:'linear', duration:250})}});
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
    jQuery(content.replace(regexp, new_id)).insertBefore(jQuery(button).closest('.addition-buttons')).hide().slideDown();

    if(association == 'alternatives') {
      jQuery(button).closest('table').find('tr:first').show();
    }
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
