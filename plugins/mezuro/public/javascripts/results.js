function results($) {
  $('.module-result-link').click(show_module_result);
}

function show_module_result(){
  var profile = jQuery('#module-result').attr('data-profile');
  var project = jQuery('#module-result').attr('data-project-id');
  var module_name = jQuery(this).attr('data-module-name');
  var endpoint = '/profile/' + profile + '/plugins/mezuro/metrics/' + project;
  show_loading_message(module_name);
  jQuery.get(endpoint, {module_name: module_name}, show_result_table);
  return false;
}

function show_loading_message(module_name) {
  jQuery('#module-result').html("Loading results for " + module_name + "...");
}

function show_result_table(content){
  jQuery('#module-result').html(content);
}