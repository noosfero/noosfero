function results($) {
  $('.mezuro-display-metrics').click(function() {
    var profile = $('#module-result').attr('data-profile');
    var project = $('#module-result').attr('data-project-id');
    var module_name = $(this).attr('data-module-name');
    var endpoint = '/profile/' + profile + '/plugins/mezuro/metrics/' + project;
    show_loading_message();
    $.get(endpoint, {module_name: module_name}, function(content) {
      $('#module-result').html(content);
      show_result_table();
    });
    return false;
  });
}
function show_loading_message() {
  jQuery('#loading-message').attr("style", "display: inline");
  jQuery('#module-result').attr("style", "display: none");
}
function show_result_table(){
  jQuery('#loading-message').attr("style", "display: none");
  jQuery('#module-result').attr("style", "display: inline");
}