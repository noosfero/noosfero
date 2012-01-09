function toogle(id){
  var suffixes = ['_hidden', '_plus', '_minus'];
  for (var i in suffixes){
    jQuery('#' + id + suffixes[i]).toggle();
  }
}