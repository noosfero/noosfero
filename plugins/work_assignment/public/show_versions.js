jQuery(".view-author-versions").each(function(index, bt){
  jQuery(bt).button({
    icons: {
      primary: "ui-icon-info"
    },
    text: false
  });
  bt.onclick = function(){
    var folderId = this.getAttribute("data-folder-id");
    var tr = jQuery(".submission-from-"+folderId);
    if ( tr[0].style.display == "none" )
      tr.show();
    else
      tr.hide();
  }
});
