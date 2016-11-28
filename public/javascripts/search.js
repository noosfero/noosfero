(function($) {
  // Pagination.
  $('#search-content').on('click', '.pagination a', function () {
    $.ajax({
      url: this.href,
      beforeSend: function(){$('#search-content, #facets').addClass('fetching')},
      complete: function() {$('#search-content, #facets').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });

  // Sorting and Views
  $('#search-filters select').change(function(){
    $('form.search_form').submit();
  });

  // Filter submenu
  $('#search-subheader select').change(function(){
    $('form.search_form').submit();
  });

  // Form Ajax submission
  $('form.search_form').submit(function () {
    $.ajax({
      url: this.action,
      data: $(this).serialize(),
      beforeSend: function(){$('#search-content, #facets').addClass('fetching')},
      complete: function() {$('#search-content, #facets').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });

  // Assets links
  $('#assets-menu a').click(function(e){
    e.preventDefault();
    var parameters = {}
    var tag = $(this).data('tag');
    var category_path = $(this).data('category_path');
    var query = $('#search-input').val();

    if(tag) parameters.tag = tag;
    if(category_path) parameters.category_path = category_path;
    if(query) parameters.query = query;

    window.location.href = $(this).attr("href") + '?' + $.param(parameters);
  });

  // Real time search
  // $(".search-input-with-suggestions").typeWatch({
  //   callback: function (value) {$('form.search_form').submit()},
  //   wait: 750,
  //   highlight: true,
  //   captureLength: 2
  // });

  $(".search-input-with-suggestions").bind('notext', function(){ $('form.search_form').submit() });
})(jQuery);
