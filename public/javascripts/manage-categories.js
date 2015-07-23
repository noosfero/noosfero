(function($){
  fetch_sub_items = function(sub_items, category){
    loading_for_button($("#category-loading-"+category)[0]);
    $.ajax({
      url: noosfero_root() + "/admin/categories/get_children",
      dataType: "html",
      data: {id: category},
      success: function(data, st, ajax){
        $(sub_items).append(data);
        $(".small-loading").remove();
        $("#show-button-"+category).fadeOut(400, function(){
          $("#hide-button-"+category).fadeIn();
        });
        $(sub_items).slideDown();
      },
      error: function(ajax, st, errorThrown) {
        alert('HTTP '+st+': '+errorThrown);
      }
    });
  };

  $(".hide-button").live('click', function(){
    var category = $(this).attr('data-category');
    var sub_items = $('#category-sub-items-'+category);
    $(this).fadeOut(400, function(){
      $("#show-button-"+category).fadeIn();
    });
    $(sub_items).slideUp();
  });

  $(".show-button").live('click', function(){
    var category = $(this).attr('data-category');
    var sub_items = $('#category-sub-items-'+category);
    if(!$(this).attr('data-fetched')){
      fetch_sub_items(sub_items, category);
      $(this).attr('data-fetched', true);
    }
    else{
      $(this).fadeOut(400, function(){
        $("#hide-button-"+category).fadeIn();
      });
      $(sub_items).slideDown();
    }
  });
})(jQuery);

