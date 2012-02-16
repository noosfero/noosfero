function show_autoreload($){
  var profile = $('#autoreload').attr('data-profile');
  var project = $('#autoreload').attr('data-project-id');
  var project_state = $('#autoreload').attr('data-project-state');
  var project_name = $('#autoreload').attr('data-project-name');
  var endpoint = '/profile/' + profile + '/plugins/mezuro/autoreload/' + project;

  jQuery('#autoreload').html('Loading results for ...' + project_name); // #FIXME
  $.get(endpoint, {project_name: project_name}, show_page_with_results);
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