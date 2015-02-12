(function(){
  function change_title_size(){
    jQuery(".event-plugin_event-block .event .title").each(function(num, el){
      var title = jQuery(el);
      console.log(title.height(), title.css("line-height"));
      if (title.height() > parseInt(title.css("line-height")) * 2) {
        title.addClass("toobig")
      }
    });
  }


  jQuery(document).ready(function(){
    change_title_size();
  });
})();