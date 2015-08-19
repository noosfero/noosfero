$('#settings_enabled').click(function(){
  $('#delivery-settings').toggle('fast');
});
$('#delivery-settings').toggle($('#settings_enabled').prop('checked'))

$('#add-new-option').click(function(){
  new_option = $('#empty-option').clone();
  new_option.removeAttr('id');
  $('#add-new-option-row').before(new_option);
  new_option.show();
  return false;
});

$('.remove-option').live('click', function(){
  $(this).closest('tr').remove();
  return false;
});

