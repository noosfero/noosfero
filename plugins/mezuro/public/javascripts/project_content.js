jQuery(function (){
  jQuery('.source-tree-link').live("click", reloadModule);
  showProjectContent();
});

function showProjectContent() {
  callAction('project_state', {}, showProjectContentFor);
}

function reloadModule(){
  var module_name = jQuery(this).attr('data-module-name');
  callAction('project_tree', {module_name: module_name }, showProjectTree);
  callAction('module_result', {module_name: module_name}, showModuleResult);
  return false;
}

function showProjectContentFor(state){
  if (state == 'ERROR')
    callAction('project_error', {}, showProjectResult);
  else if (state == 'READY') {
    callAction('project_result', {}, showProjectResult);
    callAction('project_tree', {}, showProjectTree);
    callAction('module_result', {}, showModuleResult);
  }
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

function showProjectResult(content) {
  jQuery('#project-result').html(content);
}

function showProjectTree(content){ 
  jQuery('#project-tree').html(content);
}

function showModuleResult(content){
  jQuery('#module-result').html(content);
}

function callAction(action, params, callback){
  var profile = projectContentData('profile');
  var content = projectContentData('content');
  var endpoint = '/profile/' + profile + '/plugins/mezuro/' + action + '/' + content;
  jQuery.get(endpoint, params, callback);
}

function projectContentData(data){
  return jQuery('#project-result').attr('data-' + data);
}
