jQuery(function($) {

  $(".add-friend").live('click', function(){
    clicked = $(this)
    url = clicked.attr("href");
    loading_for_button(this);
    $.post(url, function(data){
      clicked.fadeOut();
      display_notice(data);
    });
    return false;
  })

  $(".join-community").live('click', function(){
    clicked = $(this)
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
      display_notice(data);
    });
    return false;
  })

  $(".leave-community").live('click', function(){
    clicked = $(this)
    url = clicked.attr("href");
    loading_for_button(this);
    $.post(url, function(data){
      clicked.fadeOut(function(){
        clicked.css("display","none");
        clicked.parent().parent().find(".join-community").fadeIn();
        clicked.parent().parent().find(".join-community").css("display", "");
      });
      clicked.css("cursor","");
      $(".small-loading").remove();
      display_notice(data);
    });
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
});
