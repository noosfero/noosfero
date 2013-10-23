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

  $('#manage-product-details-form').live('submit', function(data) {
     var form = this;
     $(form).find('.loading-area').addClass('small-loading');
     $(form).css('cursor', 'progress');
     var request = $.ajax(form.action, {
       type: 'POST',
       dataType: 'html',
       data: $(form).serialize()
     });
     request.done(function(data, textStatus, jqXHR) {
       $('#display-manage-price-details').html(data);
       $('#manage-product-details-button').show();
     });
     request.fail(function(jqXHR, textStatus, errorThrown) {
       log.error('manage_product_details', 'Request failed', errorThrown);
       alert('manage_product_details\nRequest failed: '+ errorThrown +
             '\n\nPlease, contact the site administrator.');
       $('#display-manage-price-details .loading-area').hide();
     });
     if ($('#progressbar-icon').hasClass('ui-icon-check')) {
       display_notice($('#progressbar-icon').attr('data-price-described-notice'));
     }
     return false;
  });

  $("#add-new-cost").live('click', function() {
    $('#display-product-price-details tbody').append($('#new-cost-fields tbody').html());
    return false;
  });

  $(".cancel-new-cost").live('click', function() {
    $(this).parents('tr').remove();
    calculateValuesForBar();
    return false;
  });

  $("#product-info-form").live('submit', function(data) {
    var form = this;
    updatePriceCompositionBar(form);
  });

  $("form.edit_input").live('submit', function(data) {
    var form = this;
    inputs_cost_update_url = $(form).find('#inputs-cost-update-url').val();
    $.get(inputs_cost_update_url, function(data){
      $(".inputs-cost span").html(data);
    });
    updatePriceCompositionBar(form);
    return false;
  });

  $("#manage-product-details-form .price-details-price").live('blur', function(data) { calculateValuesForBar(); });

  function cancelPriceDetailsEdition() {
    $("#manage-product-details-button").show();
    $("#display-price-details").show();
    $("#display-manage-price-details").html('');
  };

})(jQuery);

function updatePriceCompositionBar(form) {
  bar_url = jQuery(form).find('.bar-update-url').val();
  jQuery.ajax({
    url : bar_url,
    success : function(data) {
      jQuery("#price-composition-bar").html(data);
    },
    complete : function() {
      jQuery('form #product_price').val(currencyToFloat(jQuery('#progressbar-text .product_price').html(), currency_format.separator, currency_format.delimiter));
      jQuery('form #product_inputs_cost').val(currencyToFloat(jQuery('#display-product-price-details .inputs-cost span').html(), currency_format.separator, currency_format.delimiter, currency_format.unit));
      calculateValuesForBar();
    }
  });
};

function enablePriceDetailSubmit() {
  jQuery('#manage-product-details-form input.submit').removeAttr("disabled").removeClass('disabled');
}

function calculateValuesForBar() {
  jQuery('.cancel-price-details').addClass('form-changed');
  var product_price = parseFloat(jQuery('form #product_price').val());
  var total_cost = parseFloat(jQuery('form #product_inputs_cost').val());

  jQuery('form .price-details-price').each(function() {
    var this_val = parseFloat(jQuery(this).val().replace(currency_format.separator, '.')) || 0;
    total_cost = total_cost + this_val;
  });
  enablePriceDetailSubmit();

  var described = (product_price - total_cost) == 0;
  var percentage = total_cost * 100 / product_price;
  priceCompositionBar(percentage, described, total_cost, product_price);
}

function addCommas(nStr) {
  nStr += '';
  var x = nStr.split('.');
  var x1 = x[0];
  var x2 = x.length > 1 ? '.' + x[1] : '';
  var rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, '$1' + ',' + '$2');
  }
  return x1 + x2;
}

function floatToCurrency(value, sep, del, cur) {
  var ret = '';
  if (cur) ret = cur + ' ';
  if (!sep) sep = '.';
  if (!del) del = ',';
  return ret + addCommas(parseFloat(value).toFixed(2).toString()).replace('.', '%sep%').replace(',', del).replace('%sep%', sep);
}

function currencyToFloat(value, sep, del, cur) {
  var val = value;
  if (cur) val = val.replace(cur + ' ', '');
  if (!sep) sep = '.';
  if (!del) del = ',';
  return parseFloat(val.replace(del, '').replace(sep, '.'));
}

function productionCostTypeChange(select, url, question, error_msg) {
  if (select.value == '') {
    var newType = prompt(question);
    if (newType) {
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
}

function priceCompositionBar(value, described, total_cost, price) {
  jQuery(function($) {
    var bar_area = $('#price-composition-bar');
    $(bar_area).find('#progressbar').progressbar({
      value: value
    });
    $(bar_area).find('.production_cost').html(floatToCurrency(total_cost, currency_format.separator, currency_format.delimiter));
    $(bar_area).find('.product_price').html(floatToCurrency(price, currency_format.separator, currency_format.delimiter));
    if (described) {
      $(bar_area).find('#progressbar-icon').addClass('ui-icon-check');
      $(bar_area).find('#progressbar-icon').attr('title', $('#progressbar-icon').attr('data-price-described-message'));
      $(bar_area).find('div.ui-progressbar-value').addClass('price-described');
    } else {
      $(bar_area).find('#progressbar-icon').removeClass('ui-icon-check');
      $(bar_area).find('#progressbar-icon').attr('title', $('#progressbar-icon').attr('data-price-not-described-message'));
      $(bar_area).find('div.ui-progressbar-value').removeClass('price-described');

    }
  });
}
