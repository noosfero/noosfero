(function($) {

  //Autocomplete to list members
  $('#filter-name-autocomplete').autocomplete({
   minLength:2,
   source:function(request,response){
      $.ajax({
        url:document.location.pathname+'/search_members',
        dataType:'json',
        data:{
          filter_name:request.term
        },
        success:response
      });
   }
  });
})(jQuery);


function toggle(source) {
  checkboxes = document.getElementsByName('members_filtered[]');
  for(var i=0, n=checkboxes.length;i<n;i++) {
    checkboxes[i].checked = source.checked;
  }
}
