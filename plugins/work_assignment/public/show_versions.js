jQuery(".view-author-versions").each(function(index, bt){
  bt.onclick = function(){
    var folderId = this.getAttribute("data-folder-id");
    var tr = jQuery(".submission-from-"+folderId);
    if ( tr[0].style.display == "none" )
      tr.show();
    else
      tr.hide();
  }
});
