if (typeof sortable_table === 'undefined') {

sortable_table = {

  sort_desc: function (column_class) {
    column = jQuery('.sortable-table .table-header .box-field.'+column_class);
    column.get(0).ascending = false;
    column.click();
  },

  header_click: function () {
    this.ascending = !this.ascending;
    column = jQuery(this);
    header = column.parents('.table-header');
    content = header.siblings('.table-content');
    jQuerySort(content.children('.value-row'), {find: '.'+this.classList[1], ascending: this.ascending});

    arrow = header.find('.sort-arrow').length > 0 ? header.find('.sort-arrow') : jQuery('<div class="sort-arrow"/>').appendTo(header);
    arrow.toggleClass('desc', !this.ascending).css({
      top: column.position().top,
      left: column.position().left + parseInt(column.width())/2 +
        parseInt(column.css('margin-left')) + parseInt(column.css('padding-left'))
    });
  },

  edit_arrow_toggle: function (context, toggle) {
    arrow = jQuery(context).hasClass('actions-circle') ? jQuery(context) : jQuery(context).find('.actions-circle');

    hide = arrow.find('.action-hide').toggle(toggle);
    show = arrow.find('.action-show').toggle(!toggle);
    return hide.is(':visible');
  },

},

jQuery('.sortable-table .table-header .box-field').live('click', sortable_table.header_click);

/* infrastructure */
function jQuerySort(elements, options) {
  if (typeof options === 'undefined') options = {};
  options.ascending = typeof options.ascending === 'undefined' ? 1 : (options.ascending ? 1 : -1);
  var list = elements.get();
  list.sort(function(a, b) {
    var compA = (options.find ? jQuery(a).find(options.find) : jQuery(a)).text().toUpperCase();
    var compB = (options.find ? jQuery(b).find(options.find) : jQuery(b)).text().toUpperCase();
    return options.ascending * ((compA < compB) ? -1 : (compA > compB) ? 1 : 0);
  });
  parent = elements.first().parent();
  jQuery.each(list, function(index, element) { parent.append(element); });
}

}
