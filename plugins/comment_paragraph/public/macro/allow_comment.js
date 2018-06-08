var TARGETS = 'p, ul, ol, table';

// based on https://stackoverflow.com/a/8809472
function generateUUID() {
  var time = new Date().getTime();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var random = (time + Math.random() * 16) % 16 | 0
    time = Math.floor(time / 16)
    var val = (c === 'x') ? random : (random & 0x3 | 0x8);
    return val.toString(16);
  })
}

function makeCommentable() {
  tinyMCE.activeEditor.focus();
  var startNode = tinyMCE.activeEditor.selection.getStart()
  var start = $(tinyMCE.activeEditor.selection.getStart()).closest(TARGETS);
  var end = $(tinyMCE.activeEditor.selection.getEnd()).closest(TARGETS);

  var text = $('.mce-tinymce iframe').contents().find('*');
  var selection = text.slice(text.index(start), text.index(end) + 1);
  var wasWrapped = unwrapSelection(selection)

  if (!wasWrapped) {
    var tags = start.siblings().add(start);
    var endIndex = tags.index(end) >= 0 ? tags.index(end) : tags.index(start);
    tags = tags.slice(tags.index(start), endIndex + 1);
    wrapSelection(tags);
    tinyMCE.activeEditor.selection.setCursorLocation(startNode)
  }
}

function makeAllCommentable() {
  var text = $('.mce-tinymce iframe').contents().find('*');
  var selection = text.find(TARGETS);

  var wasWrapped = unwrapSelection(selection);
  if (!wasWrapped) {
    selection.each(function(index, element) {
      if ($(element).html() !== '&nbsp;') {
        wrapSelection($(element));
      }
    })
  }
}

function unwrapSelection(selection) {
  var hasTag = false;
  selection.each(function(index, element) {
    commentTag = $(element).closest('.article_comments');
    if (commentTag.length) {
      commentTag.children().unwrap('<div class=\"article_comments\"/>');
      hasTag = true;
    }
  });
  return hasTag;
}

function wrapSelection(tags) {
  tags.wrapAll('<div class="macro article_comments paragraph_comment" ' +
                           'data-macro="comment_paragraph_plugin/allow_comment" '+
                           'data-macro-paragraph_uuid="' + generateUUID() + '"/>');
}
