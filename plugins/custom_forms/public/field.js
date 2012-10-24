jQuery('.icon-edit').live('click', function() {
  elem = this;
  jQuery.fn.colorbox({
    overlayClose: false,
    escKey: false,
    inline: true,
    href: function(){
      id = jQuery(elem).attr('field_id');
      type = jQuery('#fields_'+id+'_type').val().split('_')[0];
      selector = '#edit-'+type+'-'+id
      jQuery(selector).show();
      return selector
    }
  });
  return false;
});

jQuery('.remove-field').live('click', function(){
  id = jQuery(this).attr('field_id');
  jQuery('#field-'+id).slideDown(function(){
    jQuery('#field-'+id).remove();
  });
  return false
});

jQuery('.remove-option').live('click', function(){
  field_id = jQuery(this).attr('field_id');
  option_id = jQuery(this).attr('option_id');
  selector = '#field-'+field_id+'-option-'+option_id
  jQuery(selector).slideDown(function(){
    jQuery(selector).remove();
    jQuery.colorbox.resize();
  });
  return false
});

function updateEditText(id){
  new_id = id+1
  jQuery('#edit-text-'+id).attr('id', 'edit-text-'+new_id);
  input = jQuery('#edit-text-'+new_id+' input');
  jQuery('#edit-text-'+new_id+' .colorbox-ok-button').attr('div_id', 'edit-text-'+new_id);
  input.attr('id', input.attr('id').replace(id,new_id));
  input.attr('name', input.attr('name').replace(id,new_id));
  label = jQuery('#edit-text-'+new_id+' label');
  label.attr('for', label.attr('for').replace(id,new_id));
}

function updateEditSelect(id){
  new_id = id+1
  jQuery('#edit-select-'+id).attr('id', 'edit-select-'+new_id);
  jQuery('#edit-select-'+new_id+' .colorbox-ok-button').attr('div_id', 'edit-select-'+new_id);
  jQuery('tr[id^=field-'+id+'-option').each(function(id, element){
    jQuery(element).attr('id', jQuery(element).attr('id').replace('field-'+id,'field-'+new_id));
  });
  jQuery('#edit-select-'+new_id+' label').each(function(index, element){
    label = jQuery(element);
    label.attr('for', label.attr('for').replace(id,new_id));
  });
  jQuery('#edit-select-'+new_id+' input').each(function(index, element){
    input = jQuery(element);
    input.attr('id', input.attr('id').replace(id,new_id));
    input.attr('name', input.attr('name').replace(id,new_id));
  });
  jQuery('#edit-select-'+new_id+' .remove-option').each(function(index, element){
    jQuery(element).attr('field_id',new_id);
  });
  jQuery('#edit-select-'+new_id+' .new-option').attr('field_id',new_id);
  jQuery('#edit-select-'+new_id+' #empty-option-'+id).attr('id','empty-option-'+new_id);
}

function updateEmptyField(id){
  id = parseInt(id);
  empty_field = jQuery('#empty-field');
  empty_field.attr('last_id', (id + 1).toString());
  jQuery('#empty-field input').each(function(index, element){
    new_id = jQuery(element).attr('id').replace(id,id+1);
    jQuery(element).attr('id', new_id);
    new_name = jQuery(element).attr('name').replace(id,id+1);
    jQuery(element).attr('name', new_name);
  });
  jQuery('#empty-field select').each(function(index, element){
    new_id = jQuery(element).attr('id').replace(id,id+1);
    jQuery(element).attr('id', new_id);
    new_name = jQuery(element).attr('name').replace(id,id+1);
    jQuery(element).attr('name', new_name);
  });
  jQuery('#empty-field a').each(function(index, element){
    jQuery(element).attr('field_id', id+1);
  });
  updateEditText(id);
  updateEditSelect(id);
}

function updateEmptyOption(field_id, option_id){
  field_id = parseInt(field_id);
  option_id = parseInt(option_id);
  new_option_id = option_id+1;
  empty_option = jQuery('#empty-option-'+field_id);
  empty_option.attr('option_id',new_option_id);
  jQuery('#empty-option-'+field_id+' .remove-option').attr('option_id', new_option_id);

  name_id = ' #fields_'+field_id+'_choices_'+option_id+'_name';
  jQuery('#empty-option-'+field_id+name_id).attr('name', 'fields['+field_id+'][choices]['+new_option_id+'][name]');
  jQuery('#empty-option-'+field_id+name_id).attr('id', 'fields_'+field_id+'_choices_'+new_option_id+'_name');

  value_id = ' #fields_'+field_id+'_choices_'+option_id+'_value';
  jQuery('#empty-option-'+field_id+value_id).attr('name', 'fields['+field_id+'][choices]['+new_option_id+'][value]');
  jQuery('#empty-option-'+field_id+value_id).attr('id', 'fields_'+field_id+'_choices_'+new_option_id+'_value');
}

jQuery('#new-field').live('click', function(){
  empty_field = jQuery('#empty-field');
  id = empty_field.attr('last_id');
  edit_text = jQuery('#edit-text-'+id);
  edit_select = jQuery('#edit-select-'+id);
  new_field = empty_field.clone();
  new_field.attr('id','field-'+id);
  new_field.insertBefore(empty_field).slideDown();
  edit_text.clone().insertAfter(edit_text);
  edit_select.clone().insertAfter(edit_select);
  updateEmptyField(id);
  return false
});

jQuery('.new-option').live('click', function(){
  field_id = jQuery(this).attr('field_id');
  empty_option = jQuery('#empty-option-'+field_id);
  option_id = empty_option.attr('option_id');
  new_option = empty_option.clone();
  new_option.attr('id','field-'+field_id+'-option-'+option_id);
  new_option.insertBefore(empty_option).slideDown();
  jQuery.colorbox.resize();
  updateEmptyOption(field_id, option_id);
  return false
});

jQuery('.colorbox-ok-button').live('click', function(){
  jQuery('#'+jQuery(this).attr('div_id')).hide();
  jQuery.colorbox.close();
  return false
});
