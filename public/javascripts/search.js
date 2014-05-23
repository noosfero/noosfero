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

  // Assets links
  $('#assets-links a').click(function(e){
    e.preventDefault();
    window.location.href = $(this).attr("href") + '?query=' + $('#search-input').val();
  });

  // Real time search
  // $("input#search-input").typeWatch({
  //   callback: function (value) {$('form.search_form').submit()},
  //   wait: 750,
  //   highlight: true,
  //   captureLength: 2
  // });
})(jQuery);
