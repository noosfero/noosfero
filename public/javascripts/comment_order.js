function send_order(order, url) {
  jQuery('.article-comments-list').addClass('fetching');
  jQuery.ajax({
    url:url,
    data: {"comment_order":order},
    success: function(response) {
      jQuery(".article-comments-list").html(response);
    },
    complete: function(){ jQuery('.article-comments-list').removeClass('fetching') }
  });
}


jQuery(document).ready(function(){
  jQuery("#comment_order").change(function(){
    var url = jQuery("#page_url").val();
    send_order(this.value, url);
  });
});