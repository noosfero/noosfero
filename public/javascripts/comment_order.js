function send_order(order, url) {
  open_loading(DEFAULT_LOADING_MESSAGE);

  jQuery.ajax({
    url:url,
    data: {"comment_order":order},
    success: function(response) {
      close_loading();
      jQuery(".article-comments-list").html(response);
    },
    error: function() { close_loading() }
  });
}


jQuery(document).ready(function(){
  jQuery("#comment_order").change(function(){
    var url = jQuery("#page_url").val();
    send_order(this.value, url);
  });
});