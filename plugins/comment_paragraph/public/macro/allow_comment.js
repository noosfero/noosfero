$(window).load(function() {
  function retrieveParagraphs() {

  var selection = $('#article_body_ifr').contents().find('span.macro').closest('p');
    selection.each(function(index, element) {
      if ($(element).html() !== '&nbsp;') {
        wrapCommentable($(element));
      }
    })
  }

  var newParagraphs = retrieveParagraphs();

})

function wrapCommentable(element) {
  if(!element.hasClass('is-not-commentable')){
    element.addClass('is-commentable');
  }
}

function toggleCommentable() {
  selection = jQuery(tinyMCE.activeEditor.selection.getStart()).closest('p');

  if(selection.hasClass('is-commentable')){
    selection.removeClass('is-commentable').addClass('is-not-commentable');
    var span = jQuery(tinyMCE.activeEditor.selection.getStart()).closest('span');
    span.removeAttr('class')
    span.removeAttr('id')
    span.removeAttr('data-macro')
  } else {
    selection.removeClass('is-not-commentable').addClass('is-commentable');
  }

}
