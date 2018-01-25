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
  var div = jQuery('div.comments_list_toggle_group_' + group);
  var visible = div.is(':visible');
  var comment_group = $(this).closest('.comment-group-list')

  div.toggle('fast');
  comment_group.toggleClass('comment-group-show')
  return visible;
}

function loadCompleted(group) {
  let form = $('#comments_list_group_' + group).find('.comment_form')
  form.append("<input type='hidden' name='comment[group_id]' value='" + group + "'>")
  if(comment_group_anchor) {
    jQuery.scrollTo(jQuery(comment_group_anchor));
    comment_group_anchor = null;
  }
}
