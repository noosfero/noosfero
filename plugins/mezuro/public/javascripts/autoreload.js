function show_autoreload($){
  var profile = $('#autoreload').attr('data-profile');
  var project = $('#autoreload').attr('data-project-id');
  var project_state = $('#autoreload').attr('data-project-state');
  var project_name = $('#autoreload').attr('data-project-name');
  var endpoint = '/profile/' + profile + '/plugins/mezuro/autoreload/' + project;

  show_loading_message(project_name);
  $.get(endpoint, {project_name: project_name}, show_page_with_results);
  return false;
}

function show_loading_message(project_name) {
  jQuery('#autoreload').html("Loading results for " + project_name + "...");
}

function show_page_with_results(content){
  jQuery('#autoreload').html(content);
}
