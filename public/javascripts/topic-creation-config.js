var values_map = {2: 'self', 1: 'related', 0: 'users'};
var keys_map = {};
Object.keys(values_map).forEach(function(value){
  keys_map[values_map[value]] = value;
});
var s =  jQuery('#topic-creation-slider');

function setValue(event, ui){
  jQuery('#article_topic_creation').val(values_map[ui.value]);
}

s.slider({
  orientation: 'vertical',
  min: 0,
  max: 2,
  step: 1,
  value: keys_map[jQuery('#article_topic_creation').val()],
  range: 'max',
  change: setValue
}).each(function() {
  var opt = jQuery(this).data()['ui-slider'].options;
  var vals = opt.max - opt.min;

  for (var i = 0; i <= vals; i++) {
    var n = vals - i;
    var el = jQuery('<label>' + s.data(values_map[i]) + '</label>').css('top', ((n/vals*100) - 7 - n) + '%');
    s.append(el);
  }
});

