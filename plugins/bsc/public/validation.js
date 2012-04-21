jQuery("#bsc-plugin-sales-form").validate({
  errorPlacement: function(error, element){element.attr('title', error.text())}
});

