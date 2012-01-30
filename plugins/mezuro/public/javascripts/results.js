function results($) {
  $('.mezuro-display-metrics').click(function() {
    var profile = 'qt-calculator'; // FIXME
    var project = $('#module-result').attr('data-project-id');
    var module_name = $(this).attr('data-module-name');
    var endpoint = '/profile/' + profile + '/plugins/mezuro/metrics/' + project;
    // FIXME turn on the 'loading ...'
    $.get(endpoint, { module_name: module_name }, function(content) {
      $('#module-result').html(content);
      // FIXME turn off the 'loading ...'
    });
    return false;
  });
};