jQuery(function (){
  jQuery('#range_submit').live("click", validate_new_range_configuration);
  jQuery('#metric_configuration_submit').live("click", validate_metric_configuration);
});

function validate_code(code){
  return true;
}

function validate_metric_configuration(){
    var code = jQuery('#metric_configuration_code').val();
    if (is_null(code))
    {
        alert("Code must be filled out");
        return false;
    }
    return true;
}

function is_null(value){
    if(value == "" || value == null){
      return true;
    }
    return false;
}

function IsNotNumeric(value){
    if(value.match(/[0-9]*\.?[0-9]+/))
    {
      return false;
    }
    return true;
}

function IsNotInfinite(value){
    if(value.match(/INF/)){
      return false;
    }
    return true;
}

function validate_new_range_configuration(event){    
    var label = jQuery("#range_label").val();
    var beginning = jQuery("#range_beginning").val();
    var end = jQuery("#range_end").val();
    var color = jQuery("#range_color").val();
    var grade = jQuery("#range_grade").val();
    
    if (is_null(label) || is_null(beginning) || is_null(end) || is_null(color) || is_null(grade))
    {
        alert("Please fill all fields marked with (*).");
        return false;
    }
    if ( (IsNotNumeric(beginning) && IsNotInfinite(beginning)) || (IsNotNumeric(end) && IsNotInfinite(end)) || IsNotNumeric(grade))
    {
        alert("Beginning, End and Grade must be numeric values.");
        return false;
    }
    if (parseInt(beginning) > parseInt(end))
    {
        if(IsNotInfinite(beginning) && IsNotInfinite(end)){
          alert("End must be greater than Beginning.");
          return false;
        }
    }
    return true;
}
