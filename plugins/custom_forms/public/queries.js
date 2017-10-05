(function($) {
  $('select').change(function(){
    $('#queries-form').submit();
  });

  // Real time search
  $("#query-term").typeWatch({
    callback: function (value) {console.log("bli"); $('#queries-form').submit()},
    wait: 750,
    highlight: true,
    captureLength: 2
  });

  // Form Ajax submission
  $('form').submit(function () {
    $.ajax({
      url: this.action,
      data: $(this).serialize(),
      beforeSend: function(){$('#queries').addClass('fetching')},
      complete: function() {$('#queries').removeClass('fetching')},
      dataType: 'script'
    })
    return false;
  });
})(jQuery);
