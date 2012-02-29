jQuery(showProjectContent);

function showProjectContent() {
  callAction('project_state', {}, showProjectContentFor);
}

function showProjectContentFor(state){
  if (state == 'ERROR')
    callAction('project_error', {}, setProjectContent);
  else if (state == 'READY')
    callAction('project_result', {}, setProjectContent);
  else if (state.endsWith("ING"))
    showProjectContentAfter(20);
}

function showProjectContentAfter(seconds){
  if (seconds > 0){
    setProjectContent("Not ready. Trying again in " + seconds + " seconds");
    setTimeout(function() { showProjectContentAfter(seconds - 1);}, 1000);
  } else {
    setProjectContent("Trying now...");
    showProjectContent();
  }
}

function setProjectContent(content){
  var module_name = jQuery(this).attr('data-module-name');
  jQuery('#project-content').html(content);
  jQuery('.module-result-link').click(showProjectTree);
  callAction('module_result', {module_name: module_name}, setModuleResult);
}

function showProjectTree(){ 
  var module_name = jQuery(this).attr('data-module-name');
  callAction('project_result', {module_name: module_name}, setProjectContent);
  return false;
}

function showModuleResult(){
  var module_name = jQuery(this).attr('data-module-name');
  setModuleResult("Loading results for " + module_name + "...");
  callAction('module_result', {module_name: module_name}, setModuleResult);
  return false;
}

function setProjectResult(content){
  jQuery('#project_results').html(content);
}

function setModuleResult(content){
  jQuery('#module-result').html(content);
}

function callAction(action, params, callback){
  var profile = projectContentData('profile');
  var content = projectContentData('content');
  var endpoint = '/profile/' + profile + '/plugins/mezuro/' + action + '/' + content;
  jQuery.get(endpoint, params, callback);
}

function projectContentData(data){
  return jQuery('#project-content').attr('data-' + data);
}

function sourceNodeToggle(id){
  var suffixes = ['_hidden', '_plus', '_minus'];
  for (var i in suffixes)
    jQuery('#' + id + suffixes[i]).toggle();
}
