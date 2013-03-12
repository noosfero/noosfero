var comment_group_anchor;
jQuery(document).ready(function($) {
  var anchor = window.location.hash;
  if(anchor.length==0) return;

  var val = anchor.split('-'); //anchor format = #comment-\d+
  if(val.length!=2 || val[0]!='#comment') return; 
  if($('div[data-macro=display_comments]').length==0) return; //display_comments div must exists
  var comment_id = val[1];
  if(!/^\d+$/.test(comment_id)) return; //test for integer

  comment_group_anchor = anchor;
  var url = '/plugin/comment_group_macro/public/comment_group/'+comment_id;
  $.getJSON(url, function(data) {
    if(data.group_id!=null) {
      var button = $('div.comment_group_'+ data.group_id + ' a');
      button.click();
      $.scrollTo(button);
    }
  });
}); 
