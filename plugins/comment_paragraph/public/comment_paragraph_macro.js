jQuery(document).ready(function($) {

  //Quit if does not detect a comment for that plugin
  if($('.comment_paragraph').size() < 1)
    return;

  $(document).keyup(function(e) {
    // on press ESC key...
    if (e.which == 27) {
      hideCommentBox();
    }
  });

  //hide comments when click outside
  $('body').click(function(event){
    if ($(event.target).closest('.comment-paragraph-plugin, #comment-bubble').length === 0) {
      hideCommentBox();
    }
  });

  jQuery('#cancel-comment').die();
  jQuery('#cancel-comment').live("click", function(){
    hideCommentBox();
    return false;
  });


  function hideCommentBox() {
    $("div.side-comment").hide();
    $('.comment-paragraph-plugin').removeClass('comment-paragraph-slide-left');
    $('.comments').removeClass('selected');
  }

  function showBox(div){
    if(div.hasClass('closed')) {
      div.removeClass('closed');
      div.addClass('opened');
    }
  }

  $('.comment-paragraph-plugin .side-comments-counter').click(function(){
    var container = $(this).closest('.comment-paragraph-plugin');
    hideCommentBox();
    $('#comment-bubble').removeClass('visible');
    container.addClass('comment-paragraph-slide-left selected');
    container.find('.side-comment').show();
    if(!$('body').hasClass('logged-in') && $('meta[name="profile.allow_unauthenticated_comments"]').length == 0) {
      container.addClass('require-login-popup');
    }
    //Loads the comments
    var url = container.find('.side-comment').data('comment_paragraph_url');
    $.ajax(url).done(function(data) {
      container.find('.article-comments-list').html(data);
      if(container.find('.article-comment').length==0 || container.find('.selected_area').length) {
        container.find('.post_comment_box a.display-comment-form').click();
      } else {
        container.find('.post_comment_box').removeClass('opened');
        container.find('.post_comment_box').addClass('closed');
        container.find('.display-comment-form').show();
      }
    });
    var formDiv = container.find('.side-comment .post_comment_box');
    if(formDiv.find('.comment_form').length==0) {
      $.ajax(formDiv.data('comment_paragraph_form_url')).done(function(data) {
        formDiv.append(data);
      });
    } else {
      showBox($('.post_comment_box'));
    }

  });


  // Load comments of specific paragraph
  function processAnchor(){
    var anchor = window.location.hash;
    if(anchor.length==0) return;
    var val = anchor.split('-'); //anchor format = #comment-\d+
    if(val.length!=2 || val[0]!='#comment') return;
    if($('.comment-paragraph-plugin').length==0) return;
    var comment_id = val[1];
    if(!/^\d+$/.test(comment_id)) return; //test for integer

    var url = '/plugin/comment_paragraph/public/comment_paragraph/'+comment_id;
    $.ajax(url).done(function(data) {
      var button = $('#comment-paragraph-plugin_' + data.paragraph_uuid + ' .side-comments-counter').click();
      $('body').animate({scrollTop: parseInt(button.offset().top)}, 500);
      button.click();
    });
  }

  processAnchor();

});
