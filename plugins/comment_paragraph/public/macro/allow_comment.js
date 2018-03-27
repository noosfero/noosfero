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
	var targets = 'p, ul, ol, table'

  tinyMCE.activeEditor.focus();
  var start = $(tinyMCE.activeEditor.selection.getStart()).closest(targets);
  var end = $(tinyMCE.activeEditor.selection.getEnd()).closest(targets);

  var text = $('#article_body_ifr').contents().find('*');
  var selection = text.slice(text.index(start), text.index(end) + 1);

  var hasTag = false;
  selection.each(function(key, value) {
    commentTag = $(value).closest('.article_comments');
    if(commentTag.length) {
      commentTag.children().unwrap('<div class=\"article_comments\"/>');
      hasTag = true;
    }
  });

  if(!hasTag) {
    var tags = start.siblings().add(start);
    tags = tags.slice(tags.index(start), tags.index(end)>=0?tags.index(end)+1:tags.index(start)+1);
    tags.wrap('<div class="macro article_comments paragraph_comment" ' +
                      'data-macro="comment_paragraph_plugin/allow_comment" '+
                      'data-macro-paragraph_uuid="' + generateUUID() + '"/>');
  }
}

