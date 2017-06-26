jQuery(document).ready(function(){
  jQuery('.slider').each(function(index, s) {
    var s = jQuery(s);
    var input = jQuery('#' + s.data('input'));
    var keys = jQuery.parseJSON(s.data('keys').replace(/'/g, '"'));
    var labels = jQuery.parseJSON(s.data('labels').replace(/'/g, '"'));
    var options = jQuery.parseJSON(s.data('options').replace(/'/g, '"'));
    var range = s.data('range');

    s.slider({
      orientation: 'vertical',
      min: keys[options[0]],
      max: keys[options[options.length - 1]],
      step: 1,
      value: input.val(),
      range: range,
      change: function(event, ui) { input.val(ui.value) }
    }).each(function() {

      var opt = jQuery(this).data()['ui-slider'].options;
      var vals = opt.max - opt.min;
      jQuery.each(options, function(index, value){
        var n = vals - index;
        var el = jQuery('<label>' + labels[value] + '</label>').css('top', ((n/vals*100) - 7 - n) + '%');
        s.append(el);
      });
    });
  });
});
