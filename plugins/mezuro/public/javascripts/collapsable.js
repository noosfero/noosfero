function collapse(id){
  var suffixes = ['_list .statistic', '_plus', '_minus'];
  for (var i in suffixes){
    jQuery('#' + id + suffixes[i]).toggle();
  }
}