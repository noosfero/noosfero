//TODO Make this work with more then one slider in the page.

var s =  jQuery('.slider');
var input = jQuery('#' + s.data('input'));
var keys = jQuery.parseJSON(s.data('keys').replace(/'/g, '"'));
var values = jQuery.parseJSON(s.data('values').replace(/'/g, '"'));
var labels = jQuery.parseJSON(s.data('labels').replace(/'/g, '"'));
var options = jQuery.parseJSON(s.data('options').replace(/'/g, '"'));

function setValue(event, ui){
  input.val(values[ui.value]);
}

s.slider({
  orientation: 'vertical',
  min: keys[options[0]],
  max: keys[options[options.length - 1]],
  step: 1,
  value: keys[input.val()],
  range: 'max',
  change: setValue
}).each(function() {

  var opt = jQuery(this).data()['ui-slider'].options;
  var vals = opt.max - opt.min;
  jQuery.each(options, function(index, value){
    var n = vals - index;
    var el = jQuery('<label>' + labels[value] + '</label>').css('top', ((n/vals*100) - 7 - n) + '%');
    s.append(el);
  });
});
