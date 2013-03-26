jQuery(function (){
  jQuery('#range_submit').live("click", validate_new_range_configuration);
  jQuery('#metric_configuration_submit').live("click", validate_metric_configuration);
  jQuery('#repository_submit').live("click", validate_new_repository);
  jQuery('#reading_submit').live("click", validate_new_reading);
});

function validate_code(code){
  return true;
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

function validate_new_reading() {
  var name = jQuery('#reading_label').val();
  var grade = jQuery('#reading_grade').val();
  var color = jQuery('#reading_color').val();

  if (is_null(name) || is_null(grade) || is_null(color)){
    alert("Please fill all fields marked with (*).");
    return false;
  }

  var parser = jQuery('#labels_and_grades').attr('data-parser');
  var labels_and_grades = jQuery('#labels_and_grades').attr('data-list').split(parser);
  for (var id = 0; id < labels_and_grades.length; id = id + 2) {
    if (labels_and_grades[id] == name) {
      alert("This label already exists! Please, choose another one.");
      return false;
    } 
    
    if (labels_and_grades[id+1] == grade || labels_and_grades[id+1] == grade + ".0") {
      alert("This grade already exists! Please, choose another one.");
      return false;
    }
  }

  if (!color.match(/^[a-fA-F0-9]{6}$/)) {
      alert("This is not a valid color.");
      return false;
  } 
  return true;
}

function validate_new_repository() {
  if (allRequiredFieldsAreFilled()) {
    return addressAndTypeMatch();
  }
  return false;
}

function addressAndTypeMatch() {
  var type = jQuery('#repository_type').val();
  var address = jQuery('#repository_address').val();

  switch (type) {
    case "BAZAAR": return matchBazaar(address);
    case "CVS": return matchCVS(address);
    case "GIT": return matchGIT(address);
    case "MERCURIAL": return matchMercurial(address);
    case "REMOTE_TARBALL": return matchRemoteTarball(address);
    case "REMOTE_ZIP": return matchRemoteZIP(address);
    case "SUBVERSION": return matchSubversion(address);
  }
}

function matchBazaar(address) {
  if (address.match(/bzr/)) {
    return true;
  }
  alert("Address does not match type BAZAAR chosen.");
  return false;
}

function matchCVS(address) {
  if (address.match(/cvs/)) {
    return true;
  }
  alert("Address does not match type CVS chosen.");
  return false;
}

function matchGIT(address) {
  if (address.match(/^(http(s)?:\/\/git(hub)?\.|git:\/\/git(hub\.com|orious\.org)\/|git@git(hub\.com|orious\.org):).+.git$/)) {
    return true;
  }
  alert("Address does not match type GIT chosen.");
  return false;
}

function matchMercurial(address) {
  if (address.match(/^(http(s)?|ssh):\/\/.*hg/)) {
    return true;
  }
  alert("Address does not match type MERCURIAL chosen.");
  return false;
}

function matchRemoteTarball(address) {
  if (address.match(/\.tar(\..+)*$/)) {
    return true;
  }
  alert("Address does not match type REMOTE_TARBALL chosen.");
  return false;
}

function matchRemoteZIP(address) {
  if (address.match(/\.zip$/)) {
    return true;
  }
  alert("Address does not match type REMOTE_ZIP chosen.");
  return false;
}

function matchSubversion(address) {
  if (address.match(/^http(s)?:\/\/.+\/svn.+$/)) {
    return true;
  }
  alert("Address does not match type SUBVERSION chosen.");
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
