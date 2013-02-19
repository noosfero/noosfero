jQuery(function (){
  jQuery('#range_submit').live("click", validate_new_range_configuration);
  jQuery('#metric_configuration_submit').live("click", validate_metric_configuration);
  jQuery('#repository_submit').live("click", validate_new_repository);
});

function validate_code(code){
  return true;
}


function validate_new_repository() {
  if (allRequiredFieldsAreFilled()))
    return addressAndTypeMatch();
  return false;
}

function allRequiredFieldsAreFilled() {
  var name = jQuery('#repository_name').val();
  var address = jQuery('#repository_address').val();

  if (is_null(name) || is_null(address)) {
    alert("Please fill all fields marked with (*).");
    return false;
  }
  return true;   
}

function addressAndTypeMatch() {
  var type = jQuery('#repository_type').val();
  var address = jQuery('#repository_address').val();

  switch (type) {
    case "BAZAAR": return matchBAZAAR(address);
    case "CVS": return matchCVS(address);
    case "GIT": return matchGIT(address);
    case "MERCURIAL": return matchMercurial(address);
    case "REMOTE_TARBALL": return matchRemoteTarball(address);
    case "REMOTE_ZIP": return matchRemoteZIP(address);
    case "SUBVERSION": return matchSubversion(address);
  }
}

function matchGIT(address) {
  if (address.match(/^[ http(s)?:\/\/git(hub)?\. | git:\/\/git(hub.com | orious.org)\/ | git@git(hub.com | orious.org):].+.git$/))
    return true;
  alert("Adress does not match type GIT chosen.");
  return false;
}

function matchSubversion(address) {
  if (address.match(/^http(s)?:\/\/.+\/svn.+$/))
    return true;
  alert("Adress does not match type Subversion chosen.");
  return false;
}

function validate_metric_configuration() {
  var code = jQuery('#metric_configuration_code').val();
  if (is_null(code)) {
      alert("Code must be filled out");
      return false;
  }
  return true;
}

function is_null(value) {
  if (value == "" || value == null) {
    return true;
  }
  return false;
}

function IsNotNumeric(value) {
  if (value.match(/[0-9]*\.?[0-9]+/)) {
    return false;
  }
  return true;
}

function IsNotInfinite(value) {
  if (value.match(/INF/)) {
    return false;
  }
  return true;
}

function validate_new_range_configuration(event) {    
  var beginning = jQuery("#range_beginning").val();
  var end = jQuery("#range_end").val();

  if (is_null(beginning) || is_null(end)) {
      alert("Please fill all fields marked with (*).");
      return false;
  }
  if ( (IsNotNumeric(beginning) && IsNotInfinite(beginning)) || (IsNotNumeric(end) && IsNotInfinite(end))) {
      alert("Beginning, End and Grade must be numeric values.");
      return false;
  }
  if (parseInt(beginning) > parseInt(end)) {
      if (IsNotInfinite(beginning) && IsNotInfinite(end)) {
        alert("End must be greater than Beginning.");
        return false;
      }
  }
  return true;
}
