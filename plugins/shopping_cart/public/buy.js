shopping_cart.buy = {

  validate: function() {
    $("#cart-request-form").validate({
      submitHandler: function(form) {
        $(form).find('input.submit').attr('disabled', true);
        $('#cboxLoadingOverlay').show().addClass('loading');
        $('#cboxLoadingGraphic').show().addClass('loading');
      }
    });
  },

  update_delivery: function () {
    $('#cboxLoadingGraphic').show();
    var me = $(this);
    var profile = me.attr('data-profile-identifier');
    var id = me.val();
    var name = me.find('option:selected').attr('data-label');
    $.ajax({
      url: '/plugin/shopping_cart/update_supplier_delivery',
      dataType: "json",
      data: 'order[supplier_delivery_id]='+id,
      success: function(data, st, ajax) {
        $('#delivery-price').text(data.delivery_price);
        $('.cart-table-total-value').text(data.total_price);
        $('#delivery-name').text(name);
        $('#cboxLoadingGraphic').hide();
        display_notice(data.message)
      },
      error: function(ajax, st, errorThrown) {
        alert('Update delivery option - HTTP '+st+': '+errorThrown);
      },
    });
  },

  update_payment: function() {
    var payment = $(this)
    var form = $(payment.get(0).form)
    var changeField = form.find('#order_payment_data_change').parents('.form-group');
    var method = payment.val() == 'money' ? 'slideDown' : 'slideUp';
    changeField[method]('fast');
  },
}

$(document).ready(shopping_cart.buy.validate)
$('#order_supplier_delivery_id').on('change keyup', shopping_cart.buy.update_delivery)
$('#order_payment_data_method').on('change keyup', shopping_cart.buy.update_payment)

