function send_ajax(source_url) {
  jQuery(".link-address").autocomplete({
    source : function(request, response){
      jQuery.ajax({
        type: "GET",
        url: source_url,
        data: {query: request.term},
        success: function(result){
          response(result);
        },
        error: function(ajax, stat, errorThrown) {
          console.log('Link not found : ' + errorThrown);
        }
      });
    },

    minLength: 3
  });
}

function new_link_action(){
  send_ajax(jQuery("#page_url").val());

  jQuery(".delete-link-list-row").click(function(){
    jQuery(this).parent().parent().remove();
    return false;
  });

  jQuery(document).scrollTop(jQuery('#dropable-link-list').scrollTop());
}

jQuery(document).ready(function(){
  new_link_action();

  jQuery("#dropable-link-list").sortable({
    revert: true,
    axis: "y"
  });
});