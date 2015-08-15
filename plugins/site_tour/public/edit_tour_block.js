jQuery(document).ready(function(){
  jQuery('#edit-tour-block').on('click', '.add-item', function() {
    var container = jQuery(this).closest('.list-items');
    var new_action = container.find('#new-template>li').clone();
    new_action.show();
    container.find('.droppable-items').append(new_action);
  });

  jQuery('#edit-tour-block').on('click', '.delete-tour-block-item', function() {
    jQuery(this).parent().parent().remove();
    return false;
  });

  jQuery("#edit-tour-block .droppable-items").sortable({
    revert: true,
    axis: "y"
  });
});
