shopping_cart = {
}

function Cart(config) {
  var $ = jQuery;
  config.minimized = Cart.minimized;
  Cart.instance = this; // this may be a list on the future;
  this.cartElem = $("#cart1");
  this.cartElem.cartObj = this;
  this.contentBox = (config.minimized) ? $("#cart1 .cart-inner") : $("#cart1 .cart-inner .cart-content");
  this.itemsBox = $("#cart1 .cart-items");
  this.profileId = config.profile_id;
  this.items = {};
  this.products = config.products;
  this.empty = !config.has_products;
  this.minimized = config.minimized;
  this.hasPreviousOrders = config.has_previous_orders;
  this.visible = false;
  this.itemTemplate = _.template(jQuery('#cart-item-template').html());
  $("#cart-profile-name").text(config.profile_short_name);
  $(".cart-buy", this.cartElem).button({ icons: { primary: 'ui-icon-cart'} });
  this.load()
}

(function($){
  // Forbidding the user to request more the one action on the cart
  // simultaneously because the cart in the cookie doesn't support it.
  Cart.prototype.ajax = function(config){
    var me = this;
    this.disabled = true;
    var completeCallback = config.complete;
    config.complete = function(){
      me.disabled = false;
      if (completeCallback) completeCallback();
    };
    $.ajax(config);
  }

  Cart.prototype.load = function(){
    if (!this.empty) {
      if (!this.minimized) {
        $(this.cartElem).show();
      }
      this.addToList(this.products, true)
    } else if (this.minimized) {
      this.setQuantity(0)
    }
  }

  Cart.prototype.addToList = function(products, clear) {
    if( clear ) this.itemsBox.empty();
    var me = this;
    this.productsLength = products.length;
    for( var item,i=0; item=products[i]; i++ ) {
      this.items[item.id] = { price:item.price, quantity:item.quantity };
      this.updateTotal();
      item.priceTxt = (item.price) ? '&times;' + item.price : '';

      jQuery('#cart-item-'+item.id).remove()
      var li = jQuery(this.itemTemplate({item: item}))
      li.appendTo(this.itemsBox);

      var input = $("input", li)[0];
      input.lastValue = input.value;
      input.productId = item.id;
      input.onchange = function() {
        me.updateQuantity(this, this.productId, this.value);
      };
      // TODO: Scroll to newest item
      var liBg = li.css("background-color");
      li[0].style.backgroundColor = "#FF0";
      li.animate({ backgroundColor: liBg }, 1000);
    }

    if (!Cart.minimized) {
      if (!clear && this.empty) $(this.cartElem).show();
      if((!clear && this.empty) || (this.visible && clear)) {
        this.contentBox.hide();
      }
    } else {
      if (!clear) {
        $( ".cart-applet .cart-applet-indicator" ).addClass( 'cart-highlight' );
        $( ".cart-applet" ).effect('bounce', 300, function(){
          $( ".cart-applet .cart-applet-indicator" ).removeClass( 'cart-highlight' );
        });
      }
    }
    this.empty = false;
  }

  Cart.prototype.updateQuantity = function(input, itemId, quantity) {
    if(this.disabled) return alert(Cart.l10n.waitLastRequest);
    quantity = parseInt(quantity);
    input.disabled = true;
    var originalBg = input.style.backgroundImage;
    input.style.backgroundImage = "url(/images/loading-small.gif)";
    var me = this;
    if( quantity == NaN ) return input.value = input.lastValue;
    this.ajax({
      url: '/plugin/shopping_cart/update_quantity/'+ itemId +'?quantity='+ quantity,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) {
          log.error(data.error);
          input.value = input.lastValue;
        }
        else {
          input.lastValue = quantity;
          me.items[itemId].quantity = quantity;
          me.updateTotal();
        }
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        log.error('Add item - HTTP '+status, errorThrown);
        input.value = input.lastValue;
      },
      complete: function(){
        input.disabled = false;
        input.style.backgroundImage = originalBg;
        input.ajustSize();
      }
    });
  }

  Cart.prototype.removeFromList = function(itemId) {
    $("#cart-item-"+itemId).slideUp(500, function() {$(this).remove()});
    delete this.items[itemId];
    this.updateTotal();
  }

  Cart.addItem = function(itemId, link) {
    if(this.instance.disabled) return alert(Cart.l10n.waitLastRequest);
    if ( this.productsLength > 100 ) {
      // This limit protect the user from losing data on cookie limit.
      // This is NOT limiting to 100 products, is limiting to 100 kinds of products.
      alert(Cart.l10n.maxNumberOfItens);
      return false;
    }
    $(link).addClass('small-loading');
    var stopBtLoading = function() {
      $(link).removeClass('small-loading');
    };
    this.instance.addItem(itemId, stopBtLoading);
  }

  Cart.prototype.addItem = function(itemId, callback) {
    var me = this;
    this.ajax({
      url: '/plugin/shopping_cart/add/'+ itemId,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) {
          if (typeof data.error.message != "undefined")
            alert(data.error.message)
          else
            log.error('Shopping cart data failure', data.error);
        }
        else me.addToList(data.products);
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        log.error('Add item - HTTP '+status, errorThrown);
      },
      complete: callback
    });
  }

  Cart.removeItem = function(itemId) {
    if(this.instance.disabled) return alert(Cart.l10n.waitLastRequest);
    if( confirm(Cart.l10n.removeItem) ) this.instance.removeItem(itemId);
  }

  Cart.prototype.removeItem = function(itemId) {
    if ($("li", this.itemsBox).size() < 2) return this.clean();
    var me = this;
    this.ajax({
      url: '/plugin/shopping_cart/remove/'+ itemId,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) log.error(data.error);
        else me.removeFromList(data.product_id);
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        log.error('Remove item - HTTP '+status, errorThrown);
      }
    });
  }

  Cart.toggle = function(link) {
    if(this.instance.disabled) return alert(Cart.l10n.waitLastRequest);
    link.parentNode.parentNode.cartObj.toggle();
  }
  Cart.prototype.toggle = function() {
    if (this.empty && this.hasPreviousOrders)
      noosfero.modal.url('/plugin/shopping_cart/repeat?profile_id='+cart.profileId)
    else
      this.visible ? this.hide(true) : this.show(true)
  }

  Cart.prototype.repeat = function(order_id, callback) {
    this.ajax({
      url: '/plugin/shopping_cart/repeat/'+order_id+'?profile_id='+cart.profileId,
      success: function(data) {
        cart.addToList(data.products, true)
        callback(data)
      },
      // can't do POST because of firefox cookie reset bug
      type: 'GET', dataType: 'json', cache: false
    })
  }

  Cart.prototype.repeatCheckout = function(event, button) {
    var order_id = jQuery(button).attr('data-order-id')
    this.repeat(order_id, function(data) {
      window.location.href = '/plugin/shopping_cart/buy'
    })
    event.stopPropagation()
    return false;
  }

  Cart.prototype.repeatChoose = function(event, button) {
    var order_id = jQuery(button).attr('data-order-id')
    this.repeat(order_id, function(data) {
      noosfero.modal.close()
      cart.show(true);
    })
    event.stopPropagation()
    return false;
  }

  Cart.prototype.clearOrdersSession = function() {
    noosfero.modal.close()
    cart.hasPreviousOrders = false;
    cart.setQuantity(0)
  }

  Cart.prototype.show = function(register) {
    if(register) {
      this.ajax({
        url: '/plugin/shopping_cart/show',
        dataType: 'json',
        cache: false,
        error: function(ajax, status, errorThrown) {
          log.error('Show - HTTP '+status, errorThrown);
        }
      });
    }
    this.visible = true;
    this.contentBox.slideDown(500);
    $(".cart-toggle .str-show", this.cartElem).hide();
    $(".cart-toggle .str-hide", this.cartElem).show();

  }
  Cart.prototype.hide = function(register) {
    if(register) {
      this.ajax({
        url: '/plugin/shopping_cart/hide',
        dataType: 'json',
        cache: false,
        error: function(ajax, status, errorThrown) {
          log.error('Hide - HTTP '+status, errorThrown);
        }
      });
    }
    this.visible = false;
    this.contentBox.slideUp(500);
    $(".cart-toggle .str-show", this.cartElem).show();
    $(".cart-toggle .str-hide", this.cartElem).hide();
  }

  Cart.prototype.updateTotal = function() {
    var total = qtty = 0;
    var currency, sep = "";
    for( var itemId in this.items ) {
      var item = this.items[itemId];
      if( item.price ) {
        currency = item.price.replace(/^([^0-9]+).*$/, "$1");
        sep = item.price.charAt(item.price.length-3);
        var price = item.price.replace(/[^0-9]/g,"");
        total += item.quantity * parseFloat(price);
        qtty += item.quantity;
      }
    }
    total = Math.round(total).toString().replace(/(..)$/, sep+"$1")
    $(".cart-total b", this.cartElem).text( ( (total!=0) ? currency+" "+total : "---" ) );
    this.setQuantity(qtty)
  }

  Cart.prototype.setQuantity = function(qtty) {
    this.cartElem.find('.cart-applet-checkout').toggle(qtty > 0)
    this.cartElem.find('.cart-applet-checkout-disabled').toggle(qtty === 0)

    if (qtty === 0 && this.hasPreviousOrders)
      $(".cart-qtty", this.cartElem).text( Cart.l10n.repeatOrder )
    else
      $(".cart-qtty", this.cartElem).text( qtty )
  }

  Cart.clean = function(link) {
    if(this.instance.disabled) return alert(Cart.l10n.waitLastRequest);
    if( confirm(Cart.l10n.cleanCart) ) link.parentNode.parentNode.parentNode.cartObj.clean();
  }

  Cart.prototype.clean = function() {
    var me = this;
    this.ajax({
      url: '/plugin/shopping_cart/clean',
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) log.error(data.error);
        else{
          me.items = {};
          $(me.contentBox).slideUp(500, function() {
            $(me.itemsBox).empty();
            //me.hide();
            me.updateTotal();
            me.empty = true;
          });
        }
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        log.error('Remove item - HTTP '+status, errorThrown);
      }
    });
  }

  Cart.send_request = function(form) {
    if($(form).valid())
      Cart.instance.send_request($(form).serialize());
    return false;
  }

  Cart.prototype.send_request = function(params) {
    var me = this;
    this.ajax({
      type: 'POST',
      url: '/plugin/shopping_cart/send_request',
      data: params,
      dataType: 'script',
      cache: false,
    });
  }


  $(window).bind('beforeunload', function(){
    log('Page unload.');
    Cart.unloadingPage = true;
  });

})(jQuery);
