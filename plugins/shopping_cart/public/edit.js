jQuery('#settings_delivery').click(function(){
  jQuery('#delivery_settings').toggle('fast');
});

jQuery('#add-new-option').click(function(){
  new_option = jQuery('#empty-option').clone();
  new_option.removeAttr('id');
  jQuery('#add-new-option-row').before(new_option);
  new_option.show();
  return false;
});

jQuery('.remove-option').live('click', function(){
  jQuery(this).closest('tr').remove();
  return false;
});
