function validate_metric_configuration(){
    var code=document.forms["configuration_form"]["metric_configuration[code]"].value;
    if (is_null(code))
    {
        alert("Code must be filled out");
        return false;
    }
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

function IsNotHexadecimal(value){
    if(value.match(/[0-9a-fA-F]{1,8}/))
    {
      return false;
    }
    return true;
}

function validate_new_range_configuration(){
    var label = document.forms["new_range_form"]["range[label]"].value;
    var beginning = document.forms["new_range_form"]["range[beginning]"].value;
    var end = document.forms["new_range_form"]["range[end]"].value;
    var color = document.forms["new_range_form"]["range[color]"].value;
    var grade = document.forms["new_range_form"]["range[grade]"].value;
    
    return false;
    
    if (is_null(label) || is_null(beginning) || is_null(end) || is_null(color) || is_null(grade))
    {
        alert("Please fill all fields marked with (*)");
        return false;
    }
    if (IsNotNumeric(beginning) || IsNotNumeric(end) || IsNotNumeric(grade))
    {
        alert("Beginning, End and Grade must be numeric values");
        return false;
    }
    if (beginning > end)
    {
        alert("End must be greater than Beginning");
        return false;
    }
    if (IsNotHexadecimal(color)){
        alert("Color must be an hexadecimal value");
        return false;
    }
    return true;
}
