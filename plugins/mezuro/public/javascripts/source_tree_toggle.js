function source_tree_toggle(id){
  var suffixes = ['_hidden', '_plus', '_minus'];
  for (var i in suffixes){
    jQuery('#' + id + suffixes[i]).toggle();
  }
}
