(function($) {

  $("#manage-product-details-button").live('click', function() {
    $("#product-price-details").find('.loading-area').addClass('small-loading');
    url = $(this).attr('href');
    $.get(url, function(data){
      $("#manage-product-details-button").hide();
      $("#display-price-details").hide();
      $("#display-manage-price-details").html(data);
      $("#product-price-details").find('.loading-area').removeClass('small-loading');
    });
    return false;
  });

  $(".cancel-price-details").live('click', function() {
    $("#manage-product-details-button").show();
    $("#display-price-details").show();
    $("#display-manage-price-details").html('');
    return false;
  });

  $("#manage-product-details-form").live('submit', function(data) {
     var form = this;
     $(form).find('.loading-area').addClass('small-loading');
     $(form).css('cursor', 'progress');
     $.post(form.action, $(form).serialize(), function(data) {
       $("#display-manage-price-details").html(data);
       $("#manage-product-details-button").show();
     });
     return false;
  });

  $("#add-new-cost").live('click', function() {
    $('#display-product-price-details tbody').append($('#new-cost-fields tbody').html());
    return false;
  });

  $(".cancel-new-cost").live('click', function() {
    $(this).parents('tr').remove();
    return false;
  });

})(jQuery);

function productionCostTypeChange(select, url, question, error_msg) {
  if (select.value == '') {
    var newType = prompt(question);
    jQuery.ajax({
      url: url + "/" + newType,
      dataType: 'json',
      success: function(data, status, ajax){
        if (data.ok) {
          var opt = jQuery('<option value="' + data.id + '">' + newType + '</option>');
          opt.insertBefore(jQuery("option:last", select));
          select.selectedIndex = select.options.length - 2;
          opt.clone().insertBefore('#new-cost-fields .production-cost-selection option:last');
        } else {
          alert(data.error_msg);
        }
      },
      error: function(ajax, status, error){
        alert(error_msg);
      }
    });
  }
}
