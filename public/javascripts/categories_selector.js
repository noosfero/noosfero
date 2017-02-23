function remove_category(category_id) {
  jQuery('#selected-category-' + category_id).remove();
  $('#select-category-' + category_id  + '-link').show()
  if (jQuery('.selected-category').length == 0) {
    jQuery('#selected-categories #empty-row').show()
  }
}

// Hides categories that were already selected
function filter_category_links() {
  protect_add_button()
  var selected_categories = $('table#selected-categories tr.selected-category')
  selected_categories.each(function (index, el) {
    var category_id = $(el).data('id')
    var category_link = $('.toplevel-categories #select-category-' + category_id  + '-link')

    var should_hide = true
    var category_children = category_link.data('children')
    if (category_children) {
      should_hide = category_children.reduce(function(acc, cat_id) {
        var child_el = $('#selected-category-' + cat_id)
        return acc && child_el.length
      }, true)
    }

    if (should_hide) {
      category_link.hide()
    }
  })
}

// Hides the Add Category button if the current category was already selected
function protect_add_button() {
  var category_id = $('.categories-chain .select-subcategory-link').last().data('id')
  if ($('#selected-category-' + category_id).length) {
    $("#save-category-button").hide()
  }
}

$(document).ready(function() {
  filter_category_links()
})
