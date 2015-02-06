(function($) {
  // Pagination.
  $('#search-content').on('click', '.pagination a', function () {
    $.ajax({
      url: this.href,
      beforeSend: function(){$('#search-content').addClass('fetching')},
      complete: function() {$('#search-content').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });

  // Sorting and Views
  $('#search-filters select').change(function(){
    $('form.search_form').submit();
  });

  // Custom styled select
  $('#search-filters select').selectOrDie();

  // Form Ajax submission
  $('form.search_form').submit(function () {
    $.ajax({
      url: this.action,
      data: $(this).serialize(),
      beforeSend: function(){$('#search-content').addClass('fetching')},
      complete: function() {$('#search-content').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });

  // Assets links
  $('#assets-menu a').click(function(e){
    e.preventDefault();
    window.location.href = $(this).attr("href") + '?query=' + $('#search-input').val();
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
