var processingTree = false;
var metricName;
jQuery(function (){
  jQuery('.source-tree-link').live("click", reloadModule);
  jQuery('[show-metric-history]').live("click", display_metric_history);
  jQuery('[show-grade-history]').live("click", display_grade_history);
  jQuery('#project_date_submit').live("click", reloadProjectWithDate);
  showLoadingProcess(true);
  showProjectContent();
});

function showProjectContent() {
  callAction('project_state', {}, showProjectContentFor);
}

function display_metric_history() {
  var module_name = jQuery(this).attr('data-module-name');
  var metric_name = jQuery(this).attr('show-metric-history');
  toggle_mezuro("." + metric_name);
  metricName = metric_name;
  callAction('module_metrics_history', {module_name: module_name, metric_name: metric_name}, show_metrics);
  return false;
}

function display_grade_history() {
  var module_name = jQuery(this).attr('data-module-name');
  toggle_mezuro("#historical-grade");
  callAction('module_grade_history', {module_name: module_name}, show_grades);
  return false;
}

function show_metrics(content) {
  jQuery('#historical-' + metricName).html(content);
}

function show_grades(content) {
  jQuery('#historical-grade').html(content);
}

function toggle_mezuro(element){
  jQuery(element).toggle();
  return false;
}

function reloadModule(){
  var module_name = jQuery(this).attr('data-module-name');
  showLoadingProcess(false);
  processingTree = true;
  callAction('project_tree', {module_name: module_name }, showProjectTree);
  callAction('module_result', {module_name: module_name}, showModuleResult);
  return false;
}

function reloadProjectWithDate(date){
	reloadProject(date + "T00:00:00+00:00");
  return false;
}

function reloadProject(date){
  showLoadingProcess(true);
  
  callAction('project_result', {date: date}, showProjectResult);
  callAction('project_tree', {date: date}, showProjectTree);
  callAction('module_result', {date: date}, showModuleResult);
}

function showProjectContentFor(state){
  if (state == 'ERROR') {
    jQuery('#project-state').html('ERROR');
    callAction('project_error', {}, showProjectResult);
  }
  else if (state == 'READY') {
    jQuery('#msg-time').html('');
    jQuery('#project-state').html('READY');
    callAction('project_result', {}, showProjectResult);
    callAction('project_tree', {}, showProjectTree);
    var project_name = jQuery("#project-result").attr('data-project-name');
    callAction('module_result', {module_name: project_name}, showModuleResult);
  } 
  else if (state.endsWith("ING")) {
    jQuery('#project-state').html(state);
    jQuery('#msg-time').html("The project analysis may take long. <br/> You'll receive an e-mail when it's ready!");
    showProjectContentAfter(20);
  }	
}

function showProjectContentAfter(seconds){
  if (seconds > 0){
    setTimeout(function() { showProjectContentAfter(seconds - 10);}, 10000);
  } else {
    showProjectContent();
  }
}

function showProjectResult(content) {
  jQuery('#project-result').html(content);
}

function showProjectTree(content){ 
  processingTree = false;
  jQuery('#project-tree').html(content);
	return false;
}

function showModuleResult(content){
  if (processingTree != true){ 
    jQuery('#module-result').html(content);
  }
  return false;
}

function callAction(action, params, callback){
  var profile = projectContentData('profile');
  var content = projectContentData('content');
  var endpoint = '/profile/' + profile + '/plugin/mezuro/' + action + '/' + content;
  jQuery.get(endpoint, params, callback);
}

function projectContentData(data){
  return jQuery('#project-result').attr('data-' + data);
}

function showLoadingProcess(firstLoad){
	if(firstLoad)	
  	showProjectResult("<img src='/images/loading-small.gif'/>");
	
  showProjectTree("<img src='/images/loading-small.gif'/>");
  showModuleResult("<img src='/images/loading-small.gif'/>");
}

function sourceNodeToggle(id){
  var suffixes = ['_hidden', '_plus', '_minus'];
  for (var i in suffixes)
    jQuery('#' + id + suffixes[i]).toggle();
}
