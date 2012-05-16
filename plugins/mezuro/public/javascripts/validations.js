function validate_metric_configuration(){
    var x=document.forms["configuration_form"]["metric_configuration[code]"].value;
    if (x==null || x=="")
    {
        alert("Code must be filled out");
        return false;
    }
}
