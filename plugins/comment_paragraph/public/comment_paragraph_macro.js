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

  $('.display-comment-form').unbind();
  $('.display-comment-form').click(function(){
    var $button = $(this);
    showBox($button.parents('.post_comment_box'));
    $($button).hide();
    $button.closest('.page-comment-form').find('input').first().focus();
    return false;
  });

  //Clears all old selected_area and selected_content after submit comment
  $('[name|=commit]').click(function(){
      $('.selected_area').val("");
      $('.selected_content').val("");
  });

  //hide comments when click outside
  $('body').click(function(event){
    if ($(event.target).closest('.comment-paragraph-plugin, #comment-bubble').length === 0) {
      hideCommentBox();
      $('#comment-bubble').removeClass('visible');
      hideAllSelectedAreasExcept();
    }
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

  rangy.init();
  cssApplier = rangy.createCssClassApplier("commented-area", {normalize: false});
  cssApplierSelected = rangy.createCssClassApplier("commented-area-selected", {normalize: false});

  //Add marked text bubble
  $("body").append('\
      <a id="comment-bubble">\
          <div align="center"  class="triangle-right" >Comentar</div>\
      </a>');

  $('.comment-paragraph-plugin .side-comments-counter').click(function(){
    var container = $(this).closest('.comment-paragraph-plugin');
    var paragraphId = container.data('paragraph');
    hideAllSelectedAreasExcept(paragraphId);
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
    if(formDiv.find('.page-comment-form').length==0) {
      $.ajax(formDiv.data('comment_paragraph_form_url')).done(function(data) {
        formDiv.append(data);
      });
    }
  });


  $('#comment-bubble').click(function(event){
    var paragraph = $("#comment-bubble").data("paragraph");
    $('#comment-paragraph-plugin_' + paragraph).find('.side-comments-counter').click();
  });

  function hideAllSelectedAreasExcept(clickedParagraph, areaClass) {
    if(!areaClass) {
      areaClass = '.commented-area';
    }
    $(".comment_paragraph").each(function(){
      paragraph = $(this).closest('.comment-paragraph-plugin').data('paragraph');
      if(paragraph != clickedParagraph){
        $(this).find(areaClass).contents().unwrap();
        $(this).html($(this).html()); //XXX: workaround to prevent creation of text nodes
      }
    });
  }

  function getSelectionText() {
    var text = "";
    if (window.getSelection) {
        text = window.getSelection().toString();
    } else if (document.selection && document.selection.type != "Control") {
        text = document.selection.createRange().text;
    }
    return text;
  }

  function clearSelection() {
    if ( document.selection ) {
      document.selection.empty();
    } else if ( window.getSelection ) {
      window.getSelection().removeAllRanges();
    }
  }

  function setCommentBubblePosition(posX, posY) {
    $("#comment-bubble").css({
      top: (posY - 80),
      left: (posX - 70)
    });
  }

  //highlight area from the paragraph
  $('.comment_paragraph').mouseup(function(event) {

    hideCommentBox();

    //Don't do anything if there is no selected text
    if (getSelectionText().length == 0) {
      return;
    }

    var container = $(this).closest('.comment-paragraph-plugin');
    var paragraphId = container.data('paragraph');

    setCommentBubblePosition( event.pageX, event.pageY );

    //Prepare to open the div
    $("#comment-bubble").data("paragraph", paragraphId);
    $("#comment-bubble").addClass('visible');

    var rootElement = $(this).get(0);

    //Maybe it is needed to handle exceptions here
    try {
      var selObj = rangy.getSelection();
      var selected_area = rangy.serializeSelection(selObj, true, rootElement);
    } catch(e) {
      return;
    }
    form = container.find('.post_comment_box').find('form');

    //Register the area that has been selected at input.selected_area
    if (form.find('input.selected_area').length === 0){
      $('<input>').attr({
        class: 'selected_area',
        type: 'hidden',
        name: 'comment[comment_paragraph_selected_area]',
        value: selected_area
      }).appendTo(form)
    }else{
      form.find('input.selected_area').val(selected_area)
    }
    //Register the content being selected at input.comment_paragraph_selected_content
    var selected_content = getSelectionText();
    if (form.find('input.selected_content').length === 0){
      $('<input>').attr({
        class: 'selected_content',
        type: 'hidden',
        name: 'comment[comment_paragraph_selected_content]',
        value: selected_content
      }).appendTo(form)
    }else{
      form.find('input.selected_content').val(selected_content)
    }
    rootElement.focus();
    cssApplierSelected.toggleSelection();
    clearSelection();

    //set a one time handler to prevent multiple selections
    var fn = function() {
      hideAllSelectedAreasExcept(null, '.commented-area-selected');
      $('.comment-paragraph-plugin').off('mousedown', '.comment_paragraph', fn);
    }
    $('.comment-paragraph-plugin').on('mousedown', '.comment_paragraph', fn);
  });

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

  $(document).on('mouseenter', 'li.article-comment', function() {
    hideAllSelectedAreasExcept(null, '.commented-area-selected');
    var selected_area = $(this).find('input.paragraph_comment_area').val();
    var container = $(this).closest('.comment-paragraph-plugin');
    var rootElement = container.find('.comment_paragraph')[0];

    if(selected_area != ""){
      rangy.deserializeSelection(selected_area, rootElement);
      cssApplier.toggleSelection();
    }
  });

  $(document).on('mouseleave', 'li.article-comment', function() {
    hideAllSelectedAreasExcept();

    var container = $(this).closest('.comment-paragraph-plugin');
    var selected_area = container.find('input.selected_area').val();
    var rootElement = container.find('.comment_paragraph')[0];
    if(selected_area != ""){
      rangy.deserializeSelection(selected_area, rootElement);
      cssApplierSelected.toggleSelection();
    }
    clearSelection();
  });
});
