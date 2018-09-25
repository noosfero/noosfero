/* this hacking is necessary because the onclick function is generated
 * on a Noosfero helper (app/helpers/buttons_helper.rb:37). This helper
 * scapes the js code passed by the view (check http://api.rubyonrails.org/classes/ActionView/Helpers/JavaScriptHelper.html),
 * and without this hacking the final function argument
 * will trigger a syntax error. */
$(document).ready(function(){
  fix_onclick_argument();
});

function fix_onclick_argument() {
  var html_elements = document.getElementsByClassName('replace-onclick-arg');
  var elements_array = Array.from(html_elements);

  elements_array.map(function(element) {
    onclick_event = element.getAttribute('onclick');
    var new_onclick_event = onclick_event.replace(/\&\*/g, "'");
    element.setAttribute('onclick', new_onclick_event);
  })
}

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
      parsedUrl = newUrl.replace(/&\*/g, "'")
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

    destroy: function(button) {
      var element = $(button)
      if (!confirm(element.data('message')))
        return
      var method = jQuery('#delivery-method-'+ element.data('method-id'))
      var destroy_url = element.data('url')
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
