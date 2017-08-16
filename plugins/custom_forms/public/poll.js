jQuery(function($) {
  var placeholder = $('tr:first-child .poll-option-input').data('default-placeholder');

  function incrementName(name) {
    var match_re = /form\[fields_attributes\]\[0\]\[alternatives_attributes\]\[(\d)\]/;
    var current_index = parseInt(name.match(match_re)[1]);
    return 'form[fields_attributes][0][alternatives_attributes][' + (current_index+1).toString() + ']'
  }

  function incrementId(id) {
    var match_re = /form_fields_attributes_0_alternatives_attributes_(\d)/;
    var current_index = parseInt(id.match(match_re)[1]);
    return 'form_fields_attributes_0_alternatives_attributes_' + (current_index+1).toString();
  }

  function incrementValue(value) {
    var current_value = parseInt(value);
    return (current_value+1).toString();
  }
  $('.poll-select-type select').live('change', function(){
    if($(this).val() == 'radio')
      var new_type = 'radio';
    else if($(this).val() == 'check_box')
      var new_type = 'checkbox';

    $('.poll-option-icon').attr('type', new_type);
  });

  $('.add-poll-option .poll-option-input').live('click', function(){
    var input = $(this);
    var tr = $('.add-poll-option');
    var new_tr = tr.clone();
    var new_input = new_tr.children('.poll-option').children('.poll-option-input');
    var new_position = new_tr.children('.poll-option').children('.poll-option-position');

    new_input.attr('name', incrementName(new_input.attr('name')) + '[label]');
    new_input.attr('id', incrementId(new_input.attr('id')) + '_label');
    new_position.attr('name', incrementName(new_position.attr('name')) + '[position]');
    new_position.attr('id', incrementId(new_position.attr('id')) + '_position');
    new_position.attr('value', incrementValue(new_position.attr('value')));

    new_tr.appendTo('#poll-options');
    input.attr('placeholder', placeholder);
    tr.removeClass('add-poll-option');
  });

  $('.remove-poll-option').live('click', function(){
    var tr = $(this).closest('tr');
    var destroy_field = jQuery('input.destroy-field', tr);
    if(destroy_field.length == 1){
      destroy_field.val(1);
      tr.hide();
    }
    else
      tr.remove();

    return false;
  });

  jQuery('tbody.field-list').sortable({
    items: "tr:not(:last-child)"
  });

  var show_as = jQuery('#form_fields_attributes_0_show_as');
  if(show_as.val() == 'radio')
    var new_type = 'radio';
  else if(show_as.val() == 'check_box')
    var new_type = 'checkbox';

  $('.poll-option-icon').attr('type', new_type);
});
