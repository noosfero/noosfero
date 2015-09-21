function update_active(name_active, name_required, name_signup) {
  var required = jQuery("input[name='" + name_required + "']")[1]
  var signup = jQuery("input[name='" + name_signup + "']")[1]
  var active = jQuery("input[name='" + name_active + "']")[1]

  if(required.checked || signup.checked)
    active.checked = true
}

function active_action(obj_active, name_required, name_signup) {
  var required = jQuery("input[name='" + name_required + "']")[0]
  var signup = jQuery("input[name='" + name_signup + "']")[0]

  required.disabled = signup.disabled = !obj_active.checked
}

function required_action(name_active, name_required, name_signup) {
  var obj_required = jQuery("input[name='" + name_required + "']")[1]

  if(obj_required.checked) {
    jQuery("input[name='" + name_signup + "']")[0].checked = true
    jQuery("input[name='" + name_signup + "']")[1].checked = true
  }

  update_active(name_active, name_required, name_signup)
}

function signup_action(name_active, name_required, name_signup) {
  var obj_signup = jQuery("input[name='" + name_signup + "']")[1]

  if(!obj_signup.checked) {
    jQuery("input[name='" + name_required + "']")[0].checked = false
    jQuery("input[name='" + name_required + "']")[1].checked = false
  }

  update_active(name_active, name_required, name_signup)
}

function add_content(target_id, content, mask) {
  var id = new Date().getTime();
  var regexp = new RegExp(mask, "g");
  content = content.replace(regexp, id);
  $(target_id).append(content);
  $('#' + id).hide().slideDown();
}

function remove_content(target) {
  $(target).remove();
}

function submit_custom_field_form(selector_id, form_id, customized_type) {
  $(selector_id).attr('disabled', true);
  $(form_id).submit();
}

function manage_default_option(source) {
  var th = $(source);
  var name = th.prop('name');
  if(th.is(':checked')){
      $(':checkbox[name="'  + name + '"]').not($(source)).prop('checked',false);
  }
}

function update_default_value(source, target) {
    $(target).val(source);
}

jQuery(document).ready(function(){
  function check_fields(check, table_id, start) {
    var checkboxes = jQuery("#" + table_id + " tbody tr td input[type='checkbox']")
    for (var i = start; i < checkboxes.length; i+=3) {
      checkboxes[i].checked = check
    }
  }

  function verify_checked(fields_id){
    var checkboxes = jQuery("#" + fields_id + "_fields_conf tbody tr td input[type='checkbox']")
    for (var i = 2; i >= 0; i--) {
      var allchecked = true
      for (var j = i+3; j < checkboxes.length; j+=3) {
        if(!checkboxes[j].checked) {
          allchecked = false
          break
        }
      }

      var checkbox = jQuery(checkboxes[i+3]).attr("id").split("_")
      jQuery("#" + checkbox[0] + "_" + checkbox[checkbox.length-1]).attr("checked", allchecked)
    }
  }

  function check_all(fields_id) {
    jQuery("#" + fields_id + "_active").click(function (){check_fields(this.checked, fields_id + "_fields_conf", 0)})
    jQuery("#" + fields_id + "_required").click(function (){check_fields(this.checked, fields_id + "_fields_conf", 1)})
    jQuery("#" + fields_id +"_signup").click(function (){check_fields(this.checked, fields_id + "_fields_conf", 2)})
    verify_checked(fields_id)
  }

  check_all("person")
  check_all("enterprise")
  check_all("community")

  jQuery("input[type='checkbox']").click(function (){
    var checkbox = jQuery(this).attr("id").split("_")
    verify_checked(checkbox[0])

    if(this.checked == false) {
      jQuery("#" + checkbox[0] + "_" + checkbox[checkbox.length-1]).attr("checked", false)
    }
  })
})
