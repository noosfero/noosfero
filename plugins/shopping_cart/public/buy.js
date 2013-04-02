jQuery(document).ready(function(){
  jQuery("#cart-request-form").validate({
    submitHandler: function(form) {
      jQuery(form).find('input.submit').attr('disabled', true);
      jQuery('#cboxLoadingOverlay').show().addClass('loading');
      jQuery('#cboxLoadingGraphic').show().addClass('loading');
    }
  });
});

jQuery('#delivery_option').change(function(){
  jQuery('#cboxLoadingGraphic').show();
  me = this;
  enterprise = jQuery(me).attr('data-profile-identifier');
  option = jQuery(me).val();
  jQuery.ajax({
    url: '/plugin/shopping_cart/update_delivery_option',
    dataType: "json",
    data: 'delivery_option='+option,
    success: function(data, st, ajax) {
      jQuery('#delivery-price').text(data.delivery_price);
      jQuery('.cart-table-total-value').text(data.total_price);
      jQuery('#delivery-name').text(option);
      jQuery('#cboxLoadingGraphic').hide();
    },
    error: function(ajax, st, errorThrown) {
      alert('Update delivery option - HTTP '+st+': '+errorThrown);
    },
  });
});

jQuery('#customer_payment').change(function(){
  jQuery(this).closest('.formfieldline').next().slideToggle('fast');
});
