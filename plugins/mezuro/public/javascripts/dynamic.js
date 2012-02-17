function dynamic($) {
  $.get(endpoint('project_state'), {}, select_project_partial);
}

function endpoint(action){
  var profile = jQuery('#project-content').attr('data-profile');
  var project = jQuery('#project-content').attr('data-content');
  return '/profile/' + profile + '/plugins/mezuro/' + action + '/' + project;
}

function select_project_partial(state){
  var action, callback = show_project_content;
  if (state == 'ERROR')
    action = 'project_error';
  else if (state == 'READY')
    action = 'project_result';
  else {
//    wait(10);
    action = 'project_state';
    callback = select_project_partial;
  }
  jQuery.get(endpoint(action), {}, callback);
}

//function wait(seconds){
//  var remaining = seconds;
//  while(remaining > 0){
//    setTimeout(function() {
//        jQuery('#project-content').html("Processing. Trying again in " + remaining + " seconds");
//      }, 1000);
//    remaining--;
//  }
//  jQuery('#project-content').html("Trying now...");
//}

function show_project_content(content){
  jQuery('#project-content').html(content);
  jQuery('.module-result-link').click(show_module_result);
  return false;
}

function show_module_result(){
  var module_name = jQuery(this).attr('data-module-name');
  jQuery('#module-result').html("Loading results for " + module_name + "...");
  jQuery.get(endpoint('module_result'), { module_name: module_name }, show_result_table);
  return false;
}

function show_result_table(content){
  jQuery('#module-result').html(content);
}
