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
    if ( !$(this).hasClass('form-changed') ) {
      cancelPriceDetailsEdition();
    } else {
      if (confirm($(this).attr('data-confirm'))) {
        cancelPriceDetailsEdition();
      }
    }
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
     if ($('#progressbar-icon').hasClass('ui-icon-check')) {
       display_notice($('#price-described-notice').show());
     }
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

  $("#product-info-form").live('submit', function(data) {
    var form = this;
    updatePriceCompositionBar(form);
  });

  $("form.edit_input").live('submit', function(data) {
    var form = this;
    updatePriceCompositionBar(form);
    inputs_cost_update_url = $(form).find('#inputs-cost-update-url').val();
    $.get(inputs_cost_update_url, function(data){
      $(".inputs-cost").html(data);
    });
    return false;
  });

  $("#manage-product-details-form .price-details-price").live('keydown', function(data) {
     $('.cancel-price-details').addClass('form-changed');
     var product_price = parseFloat($('form #product_price').val());
     var total_cost = parseFloat($('#product_inputs_cost').val());

     $('form .price-details-price').each(function() {
       total_cost = total_cost + parseFloat($(this).val());
     });
     enablePriceDetailSubmit();

     var described = (product_price - total_cost) == 0;
     var percentage = total_cost * 100 / product_price;
     priceCompositionBar(percentage, described, total_cost, product_price);
  });

  function cancelPriceDetailsEdition() {
    $("#manage-product-details-button").show();
    $("#display-price-details").show();
    $("#display-manage-price-details").html('');
  };

  function updatePriceCompositionBar(form) {
    bar_url = $(form).find('.bar-update-url').val();
    $.get(bar_url, function(data){
      $("#price-composition-bar").html(data);
    });
  };

  function enablePriceDetailSubmit() {
    $('#manage-product-details-form input.submit').removeAttr("disabled").removeClass('disabled');
  };

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

function priceCompositionBar(value, described, total_cost, price) {
  jQuery(function($) {
    var bar_area = $('#price-composition-bar');
    $(bar_area).find('#progressbar').progressbar({
      value: value
    });
    $(bar_area).find('.production-cost').html(total_cost.toFixed(2));
    $(bar_area).find('.product_price').html(price.toFixed(2));
    if (described) {
      $(bar_area).find('#progressbar-icon').addClass('ui-icon-check');
      $(bar_area).find('#progressbar-icon').attr('title', $('#price-described-message').html());
      $(bar_area).find('div.ui-progressbar-value').addClass('price-described');
    } else {
      $(bar_area).find('#progressbar-icon').removeClass('ui-icon-check');
      $(bar_area).find('#progressbar-icon').attr('title', $('#price-not-described-message').html());
      $(bar_area).find('div.ui-progressbar-value').removeClass('price-described');

    }
  });
}
