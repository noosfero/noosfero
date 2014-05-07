(function($) {
  //TODO Sorting
  // Sorting and pagination links.
  $('#search-content .pagination a').live('click',
    function () {
      $.getScript(this.href);
      return false;
    }
  );

  // Search form
  $('form.search_form').submit(function () {
    $.ajax({
      url: this.action,
      data: $(this).serialize(),
      beforeSend: function(){$('#search-content').addClass('searching')},
      complete: function() {$('#search-content').removeClass('searching')},
      dataType: 'script'
    })
    return false;
  });
})(jQuery);
