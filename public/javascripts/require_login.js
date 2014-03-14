(function($) {
  $(window).bind('userDataLoaded', function(event, data) {
    $(".require-login-popup").live('click', function(){
      clicked = $(this);
      url = clicked.attr("href");
      if(url!=undefined && url!='' && url!='#') {
        if(!data.login) {
          url = $.param.querystring(url, "require_login_popup=true");
        }
        loading_for_button(this);
        $.post(url, function(data){
          if(data.require_login_popup) {
            $('#link_login').click(); //TODO see a better way to show login popup
          }
        }).complete(function() {
          clicked.css("cursor","");
          $(".small-loading").remove();
        });
      } else {
        $('#link_login').click();
      }
      return false;
    });
  });
})(jQuery);
