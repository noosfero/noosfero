var comment_group_anchor;
jQuery(document).ready(function($) {
  var anchor = window.location.hash;
  if(anchor.length==0) return;

  var val = anchor.split('-'); //anchor format = #comment-\d+
  if(val.length!=2 || val[0]!='#comment') return;
  if($('div[data-macro=comment_group_plugin\\/allow_comment]').length==0) return; //comment_group_plugin/allow_comment div must exists
  var comment_id = val[1];
  if(!/^\d+$/.test(comment_id)) return; //test for integer

  comment_group_anchor = anchor;
  var url = '/plugin/comment_group/public/comment_group/'+comment_id;
  $.getJSON(url, function(data) {
    if(data.group_id!=null) {
      var button = $('div.comment_group_'+ data.group_id + ' a');
      button.click();
      $.scrollTo(button);
    }
  });
});

function toggleGroup(group) {
  var div = jQuery('div.comments_list_toggle_group_'+group);
  var visible = div.is(':visible');
  if(!visible)
    jQuery('div.comment-group-loading-'+group).addClass('comment-button-loading');

  div.toggle('fast');
  return visible;
}

function loadCompleted(group) {
  jQuery('div.comment-group-loading-'+group).removeClass('comment-button-loading')
  if(comment_group_anchor) {
    jQuery.scrollTo(jQuery(comment_group_anchor));
    comment_group_anchor = null;
  }
}
