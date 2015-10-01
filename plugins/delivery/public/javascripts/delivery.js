
delivery = {

  order: {
    select: {

      onChange: function(input) {
        var input = jQuery(input)
        var deliverySelect = input.parents('.order-delivery-select')

        var option = input.find('option:selected')
        var typeData = option.attr('data-type')
        var isPickup = typeData == 'pickup'
        var instructionsData = option.attr('data-instructions')
        var labelData = option.attr('data-label')

        var instructions = deliverySelect.find('.instructions')
        instructions.html(instructionsData)
        var consumerData = deliverySelect.find('.consumer-delivery-data')
        if (isPickup) {
          consumerData.slideUp('fast')
        } else {
          consumerData.slideDown('fast')
        }
      },

    },
  },

  option: {
  },

  method: {

    view: {
      edition: function() {
        return jQuery('#delivery-method-edition')
      },
      listing: function() {
        return jQuery('#delivery-method-list')
      },
      toggle: function () {
        jQuery('#delivery-method-list, #delivery-method-edition').fadeToggle();
      },
    },

    changeType: function(select) {
      select = jQuery(select)
    },

    new: function(newUrl) {
      this.edit(newUrl)
    },

    edit: function(editUrl) {
      var listing = this.view.listing()
      var edition = this.view.edition()

      loading_overlay.show(listing)
      jQuery.get(editUrl, function(data) {
        edition.html(data)
        delivery.method.view.toggle();
        loading_overlay.hide(listing)
      });
    },

    save: function(form) {
      var listing = this.view.listing()
      var edition = this.view.edition()

      jQuery(form).ajaxSubmit({
        beforeSubmit: function() {
          loading_overlay.show(edition)
        }, success: function(data) {
          listing.html(data);
          delivery.method.view.toggle();
          loading_overlay.hide(edition)
        },
      })
      return false;
    },

    destroy: function(id, confirmText, destroy_url) {
      if (!confirm(confirmText))
        return
      var method = jQuery('#delivery-method-'+id)
      jQuery.post(destroy_url, function() {
        method.fadeOut(function() {
          method.remove()
        })
      })
    },

  },

  option: {

    add: function(newUrl) {
      $.getScript(newUrl)
    },
  },

};
