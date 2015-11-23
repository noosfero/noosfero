if (typeof toggle_edit === 'undefined') {

toggle_edit = {

  _editing: jQuery(),
  _isInner: false,

  setEditing: function (value) {
    toggle_edit._editing = jQuery(value);
  },
  editing: function () {
    return toggle_edit._editing.first();
  },
  isEditing: function () {
    return toggle_edit.editing().first().hasClass('edit');
  },

  edit: function (value_row) {
    toggle_edit.setEditing(value_row);
    toggle_edit.value_row.toggle_edit();
  },

  toggle: function() {
    toggle_edit.editing().toggle();
  },
  hide: function() {
    toggle_edit.editing().hide();
  },

  target: {
    isToggle: function (target) {
      return (jQuery(target).hasClass('box-edit-link') && !toggle_edit.isEditing()) ||
        target.hasAttribute('toggle-edit') || jQuery(target).parents().attr('toggle-edit') != undefined;
    },
    isToggleIgnore: function (target) {
      return target.hasAttribute('toggle-ignore') || jQuery(target).parents().attr('toggle-ignore') != undefined;
    },
  },

  document_click: function(event) {
    if (toggle_edit.target.isToggleIgnore(event.target))
      return;

    var isToggle = toggle_edit.target.isToggle(event.target);
    var out = toggle_edit.value_row.locate(event.target).length == 0;
    if (!isToggle && out && toggle_edit.isEditing()) {
      toggle_edit.value_row.toggle_edit();
    }

    return true;
  },

  open_anchor: function () {
    try {
      el = jQuery(window.location.hash);
      toggle_edit.value_row.reload();
      if (el.hasClass('value-row')) {
        toggle_edit.setEditing(el);
        toggle_edit.value_row.toggle_edit();
      }
    } catch(e) {
      // catch invalid anchor errors to avoid break in document.ready event chain
    }
  },

  value_row: {

    locate: function (context) {
      return jQuery(context).hasClass('value-row') ? jQuery(context) : jQuery(context).parents('.value-row');
    },

    mouseenter: function () {
      if (jQuery(this).attr('without-hover') != undefined)
        return;
      jQuery(this).addClass('hover');
    },

    mouseleave: function () {
      if (jQuery(this).attr('without-hover') != undefined)
        return;
      jQuery(this).removeClass('hover');
    },

    click: function (event) {
      if (toggle_edit.target.isToggleIgnore(event.target))
        return true;

      var value_row = toggle_edit.value_row.locate(event.target);
      var now_isInner = value_row.length > 1;
      var isToggle = toggle_edit.target.isToggle(event.target);
      var isAnother = value_row.get(0) != toggle_edit.editing().get(0) || (now_isInner && !toggle_edit._isInner);
      if (now_isInner && !toggle_edit._isInner)
        toggle_edit.setEditing(value_row);
      toggle_edit._isInner = now_isInner;

      if (!isToggle && value_row.attr('without-click-edit') != undefined)
        return;

      if (isToggle) {
        if (isAnother)
          toggle_edit.value_row.toggle_edit();
        toggle_edit.edit(value_row);

        return false;
      } else if (isAnother || !toggle_edit.isEditing()) {
        if (toggle_edit.isEditing())
          toggle_edit.value_row.toggle_edit();
        toggle_edit.setEditing(value_row);
        if (!toggle_edit.isEditing())
          toggle_edit.value_row.toggle_edit();

        return false;
      }

      return true;
    },

    toggle_edit: function (toggle) {
      toggle_edit.editing().toggleClass('edit', toggle);
      eval(toggle_edit.editing().attr('toggle-edit'));
      if (!toggle_edit.isEditing()) {
        if (toggle_edit._editing.length > 1)
          toggle_edit.setEditing(jQuery(toggle_edit._editing[1]));
        else
          toggle_edit.setEditing(jQuery());
      }
    },
    reload: function () {
      toggle_edit.value_row.toggle_edit(true);
    },
  },
};

jQuery('.value-row').live('mouseenter', toggle_edit.value_row.mouseenter);
jQuery('.value-row').live('mouseleave', toggle_edit.value_row.mouseleave);
jQuery('.value-row').live('click', toggle_edit.value_row.click);
jQuery(document).click(toggle_edit.document_click);
jQuery(document).ready(toggle_edit.open_anchor);
jQuery(window).bind('hashchange', toggle_edit.open_anchor);

}
