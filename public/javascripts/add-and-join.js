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
    clicked = $(".leave-community");
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
    clicked = $(this)
    url = clicked.attr("href");
    loading_for_button(this);
    $.post(url, function(data){
      clicked.fadeOut();
      clicked.parents('.profiles-suggestions').html(data);
    });
    return false;
  })

  /* After adding a suggestion need to remove it from list */
  $(".accept-suggestion").live('click', function(){
    clicked = $(this)
    loading_for_button(this);
    url = clicked.attr("href");
    remove_suggestion = clicked.parents('li').find('.remove-suggestion');
    remove_url = remove_suggestion.attr('href')
    $.post(remove_url, function(suggestions_data){
      remove_suggestion.parents('.profiles-suggestions').html(suggestions_data);
      $.post(url, function(add_data){
        clicked.parents('li').fadeOut();
      });
    });
    return false;
  })

});
