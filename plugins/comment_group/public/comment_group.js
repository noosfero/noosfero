function getNextGroupId() {
  max = -1;
  groups = jQuery('#article_body_ifr').contents().find('.article_comments');
  groups.each(function(key, value) {
    value = jQuery(value).attr('data-macro-group_id');
    if(value>max) max = parseInt(value);
  });
  return max+1;
}

function makeCommentable() {
  tinyMCE.activeEditor.focus();
  start = jQuery(tinyMCE.activeEditor.selection.getStart()).closest('p');
  end = jQuery(tinyMCE.activeEditor.selection.getEnd()).closest('p');

  //text = start.parent().children();
  text = jQuery('#article_body_ifr').contents().find('*');
  selection = text.slice(text.index(start), text.index(end)+1);
  
  hasTag = false;
  selection.each(function(key, value) {
    commentTag = jQuery(value).closest('.article_comments');
    if(commentTag.length) {
      commentTag.children().unwrap('<div class=\"article_comments\"/>');
      hasTag = true;
    }
  });

  if(!hasTag) {
    tags = start.siblings().add(start);
    tags = tags.slice(tags.index(start), tags.index(end)>=0?tags.index(end)+1:tags.index(start)+1);
    tags.wrapAll('<div class=\"macro article_comments\" data-macro=\"display_comments\" data-macro-group_id=\"'+getNextGroupId()+'\"/>');

    contents = jQuery('#article_body_ifr').contents();
    lastP = contents.find('p.article_comments_last_paragraph');
    if(lastP.text().trim().length > 0) {
      lastP.removeClass('article_comments_last_paragraph');
    } else {
      lastP.remove();
    }
    lastDiv = contents.find('div.article_comments').last();
    if(lastDiv.next().length==0) {
      lastDiv.after("<p class='article_comments_last_paragraph'>&nbsp;</p>");
    }
  }
}

