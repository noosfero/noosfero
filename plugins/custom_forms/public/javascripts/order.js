jQuery("select.filter").change(function(){
  var filter = jQuery(this).find("option:selected").val();
  var attribute = jQuery(this).attr('name');
  redirect_to('?' + attribute + '=' + filter);
});
