noosfero.add_and_join = {
  locales: {
    leaveConfirmation: '',
  },
};

jQuery(function($) {

  $(".add-friend").live('click', function(){
    clicked = $(this);
    url = clicked.attr("href");
    loading_for_button(this);
    $.post(url, function(data){
      clicked.fadeOut();
      display_notice(data);
    });
    return false;
  })

  $(".join-community").live('click', function(){
    clicked = $(this);
    url = clicked.attr("href");
    loading_for_button(this);
    $.post(url, function(data){
      clicked.fadeOut(function(){
        clicked.css("display","none");
        clicked.parent().parent().find(".leave-community").fadeIn();
        clicked.parent().parent().find(".leave-community").css("display", "");
      });
      clicked.css("cursor","");
      $(".small-loading").remove();
      display_notice(data.message);
    }, "json");
    return false;
  })

  $(".leave-community").live('click', function(){
    if (!confirm(noosfero.add_and_join.locales.leaveConfirmation))
      return false;
    clicked = $(this);
    url = clicked.attr("href");
    loading_for_button(this);
    $.post(url, function(data){
      if(data.redirect_to){
        document.location.href = data.redirect_to;
      }
      else if(data.reload){
        document.location.reload(true);
      }
      else{
        clicked.fadeOut(function(){
          clicked.css("display","none");
          clicked.parent().parent().find(".join-community").fadeIn();
          clicked.parent().parent().find(".join-community").css("display", "");
        });
        clicked.css("cursor","");
        $(".small-loading").remove();

        display_notice(data.message);
      }
    }, "json");
    return false;
  })

  $(".person-trigger").click(function(){
    clicked = $(this);
    url = clicked.attr("url");
    $.get(url, function(data){
      if(data == "true"){
        clicked.parent().find(".add-friend").fadeOut(function(){
          clicked.parent().find(".send-an-email").fadeIn();
        })
      }
      else if(data == "false"){
        clicked.parent().find(".send-an-email").fadeOut(function(){
          clicked.parent().find(".add-friend").fadeIn();
        });
      }
    })
  })

  $(".community-trigger").click(function(){
    clicked = $(this);
    url = clicked.attr("url");
    $.get(url, function(data){
      if(data == "true"){
        clicked.parent().find(".join-community").fadeOut(function(){
          clicked.parent().find(".leave-community").fadeIn();
          clicked.parent().find(".send-an-email").fadeIn();
        });
      }
      else if(data == "false"){
        clicked.parent().find(".send-an-email").fadeOut();
        clicked.parent().find(".leave-community").fadeOut(function(){
          clicked.parent().find(".join-community").fadeIn();
        });
      }
    })
  })

  $(".enterprise-trigger").click(function(){
    clicked = $(this);
    url = clicked.attr("url");
    $.get(url, function(data){
      if(data == "true")
        clicked.parent().find(".send-an-email").fadeIn();
      else if(data == "false")
        clicked.parent().find(".send-an-email").fadeOut();
    })
  })

  $(".comment-trigger").live('click', function(){
    clicked = $(this);
    url = clicked.attr("url");
    $.get(url, function(data){
      ids = [];
      if(data && data.ids) {
        for(var i=0; i<data.ids.length; i++) {
          clicked.parent().find(data.ids[i]).fadeIn();
          ids.push(data.ids[i]);
        }
      }
      clicked.parent().find('.comment-action-extra').each(function() {
        if($.inArray('#'+$(this).attr('id'), ids))
          $(this).fadeOut();
      });
    })
    return false;
  })

  $(".remove-suggestion").live('click', function(){
    clicked = $(this);
    removeSuggestionFromList(clicked);
  })

  $(".accept-suggestion").live('click', function(){
    clicked = $(this)
    loading_for_button(this);
    url = clicked.attr("href");
    removeSuggestionFromList(clicked.parents('li').find('.remove-suggestion'));
    $.post(url, function(add_data){
      clicked.parents('li').fadeOut();
    });
    return false;
  })

});

/* Used after clicking on remove and after adding a suggestion */
function removeSuggestionFromList( element ) {
  url = element.attr("href");
  loading_for_button(element);
  jQuery.post(url, function(data){
    element.fadeOut();
    element.parents('.profiles-suggestions').html(data);
  });
}
