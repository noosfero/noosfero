jQuery(document).ready(function($){
  $("#memberships_filter").change(function(){
    var filter = $(this).find("option:selected").val();
    redirect_to('?filter_type=' + filter);
  });
});
