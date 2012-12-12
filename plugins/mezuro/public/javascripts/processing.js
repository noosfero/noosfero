var processingTree = false;
var metricName;
jQuery(function (){
  jQuery('.source-tree-link').live("click", reloadModule);
  jQuery('[show-metric-history]').live("click", display_metric_history); //TODO review for project history
  jQuery('[show-grade-history]').live("click", display_grade_history); //TODO review for project history
  jQuery('#project_date_submit').live("click", reloadProjectWithDate); //TODO review for project history
  showLoadingProcess(true);
  showProcessing();
});

function showProcessing() {
  callAction('processing', 'processing', {}, showProcessingFor);
}

//TODO review for project history
function display_metric_history() {
  var module_name = jQuery(this).attr('data-module-name');
  var metric_name = jQuery(this).attr('show-metric-history');
  toggle_mezuro("." + metric_name);
  metricName = metric_name;
  callAction('module_result', 'metric_result_history', {metric_name: metric_name, module_result_id: module_result_id}, show_metrics);
  return false;
}

//TODO review for project history
function display_grade_history() {
  var module_name = jQuery(this).attr('data-module-name');
  toggle_mezuro("#historical-grade");
  callAction('module_result', 'module_result_history', {module_result_id: module_result_id}, show_grades);
  return false;
}

//TODO review for project history
function show_metrics(content) {
  jQuery('#historical-' + metricName).html(content);
}

//TODO review for project history
function show_grades(content) {
  jQuery('#historical-grade').html(content);
}

function toggle_mezuro(element){
  jQuery(element).toggle();
  return false;
}

//TODO Waiting for ModuleResultController refactoring
function reloadModule(){
  var results_root_id = jQuery(this).attr('results_root_id');
  showLoadingProcess(false);
  processingTree = true;
//  callAction('module_result', 'project_tree', {results_root_id: results_root_id }, showProjectTree);
  callAction('module_result', 'module_result', {results_root_id: results_root_id}, showModuleResult);
  return false;
}

//TODO review for project history
function reloadProjectWithDate(date){
	reloadProject(date + "T00:00:00+00:00");
  return false;
}

//TODO review for project history
function reloadProject(date){
  showLoadingProcess(true);
  
  callAction('processing', 'processing', {date: date}, showProjectResult);
//  callAction('module_result', 'project_tree', {date: date}, showProjectTree);
  callAction('module_result', 'module_result', {date: date}, showModuleResult);
}

function showProcessingFor(state){
  if (state == 'ERROR') {
    jQuery('#project-state').html('<div style="color:Red">ERROR</div>');
    callAction('processing', 'processing_error', {}, showProcessing);
  }
  else if (state == 'READY') {
    jQuery('#msg-time').html('');
    jQuery('#processing-state').html('<div style="color:Green">READY</div>');
    callAction('processing', 'processing', {}, showProcessing);
//    callAction('processing','project_tree', {}, showProjectTree);
    //var module_result_id = jQuery("#processing").attr('results_root_id'); //TODO Waiting for ModuleResultController refactoring
    callAction('module_result', 'module_result', {module_result_id: module_result_id}, showModuleResult); //TODO Waiting for ModuleResultController refactoring
  } 
  else if (state.endsWith("ING")) {
    jQuery('#processing-state').html('<div style="color:DarkGoldenRod">'+ state +'</div>');
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
  jQuery('#processing').html(content);
}

//function showProjectTree(content){ 
//  processingTree = false;
//  jQuery('#project-tree').html(content);
//	return false;
//}

//TODO Waiting for ModuleResultController refactoring
function showModuleResult(content){
//  if (processingTree != true){
    jQuery('#module-result').html(content);
//  }
//  return false;
}

function callAction(controller, action, params, callback){
  var profile = projectContentData('profile');
  var content = projectContentData('content');
  var endpoint = '/profile/' + profile + '/plugin/mezuro/' + controller + '/' + action + '/' + content;
  jQuery.get(endpoint, params, callback);
}

function projectContentData(data){
  return jQuery('#processing').attr('data-' + data);
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
