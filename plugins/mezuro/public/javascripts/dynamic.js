function dynamic($) {
  $('.module-result-link').click(show_module_result);
}

function endpoint(action){
  var profile = jQuery('#ids').attr('data-profile');
  var project = jQuery('#ids').attr('data-content');
  return '/profile/' + profile + '/plugins/mezuro/' + action + '/' + project;
}

function show_module_result(){
  var module_name = jQuery(this).attr('data-module-name');
  jQuery('#module-result').html("Loading results for " + module_name + "...");
  jQuery.get(endpoint('module_result'), {module_name: module_name}, show_result_table);
  return false;
}

function show_result_table(content){
  jQuery('#module-result').html(content);
}

function show_autoreload($){
  jQuery('#autoreload').html('Loading results for ...' + project_name); // #FIXME
  jQuery.get(endpoint('project_result'), {project_name: project_name}, show_page_with_results);
  return false;
}

function show_page_with_results(content){
  var done = true; // FIXME; test the content in some way
  if (done) {
    jQuery('#autoreload').html(content);
  } else {
    var wait = 10; // FIXME; how many seconds to wait?
    setTimeout(function() {
      show_autoreload(jQuery);
    }, wait * 1000);
  }
}