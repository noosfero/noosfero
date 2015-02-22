function Cart(config) {
  var $ = jQuery;
  Cart.instance = this; // this may be a list on the future;
  this.cartElem = $("#cart1")[0];
  this.cartElem.cartObj = this;
  this.contentBox = $("#cart1 .cart-content");
  this.itemsBox = $("#cart1 .cart-items");
  this.items = {};
  this.empty = !config.has_products;
  this.visible = false;
  $(".cart-buy", this.cartElem).button({ icons: { primary: 'ui-icon-cart'} });
  if (!this.empty) {
    $(this.cartElem).show();
    this.visible = config.visible;
    this.addToList(config.products, true)
  }
}

(function($){

  // Forbidding the user to request more the one action on the cart
  // simultaneously because the cart in the cookie doesn't supports it.
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

  Cart.prototype.addToList = function(products, clear) {
    if( clear ) this.itemsBox.empty();
    var me = this;
    this.productsLength = products.length;
    for( var item,i=0; item=products[i]; i++ ) {
      this.items[item.id] = { price:item.price, quantity:item.quantity };
      this.updateTotal();
      var liId = "cart-item-"+item.id;
      var li = $("#"+liId);
      if( !li[0] ) li = $('<li id="'+liId+'"></li>\n').appendTo(this.itemsBox);
      li.empty();
      $('<div class="picture" style="background-image:url('+item.picture+')"></div>' +
        '<span class="item-name">'+ item.name +'</span>' +
        '<div class="item-price">' +
        '<input size="1" value="'+item.quantity+'" />'+ (item.price ? '&times; '+ item.price : '') +'</div>' +
        ' <a href="remove:'+item.name+'" onclick="Cart.removeItem('+item.id+'); return false"' +
        ' class="button icon-remove"><span>remove</span></a>'
       ).appendTo(li);
      var input = $("input", li)[0];
      input.lastValue = input.value;
      input.productId = item.id;
      input.ajustSize = function() {
        var len = this.value.toString().length;
        if(len > 2) len--;
        this.style.width = len+"em";
      };
      input.ajustSize();
      input.onchange = function() {
        me.updateQuantity(this, this.productId, this.value);
      };
      // TODO: Scroll to newest item
      var liBg = li.css("background-color");
      li[0].style.backgroundColor = "#FF0";
      li.animate({ backgroundColor: liBg }, 1000);
    }

    if (!clear && this.empty) $(this.cartElem).show();
    if((!clear && this.empty) || (this.visible && clear)) {
      this.contentBox.hide();
      this.show(!clear);
    }
    this.empty = false;
  }

  Cart.prototype.updateQuantity = function(input, itemId, quantity) {
    if(this.disabled) return alert(shoppingCartPluginL10n.waitLastRequest);
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
    if(this.instance.disabled) return alert(shoppingCartPluginL10n.waitLastRequest);
    if ( this.productsLength > 100 ) {
      // This limit protect the user from losing data on cookie limit.
      // This is NOT limiting to 100 products, is limiting to 100 kinds of products.
      alert(shoppingCartPluginL10n.maxNumberOfItens);
      return false;
    }
    link.intervalId = setInterval(function() {
      $(link).addClass('loading');
      steps = ['w', 'n', 'e', 's'];
      if( !link.step || link.step==3 ) link.step = 0;
      link.step++;
      $(link).button({ icons: { primary: 'ui-icon-arrowrefresh-1-'+steps[link.step]}})
    }, 100);
    var stopBtLoading = function() {
      clearInterval(link.intervalId);
      $(link).removeClass('loading');
      $(link).button({ icons: { primary: 'ui-icon-cart'}});
    };
    this.instance.addItem(itemId, stopBtLoading);
  }

  Cart.prototype.addItem = function(itemId, callback) {
    var me = this;
    this.ajax({
      url: '/plugin/shopping_cart/add/'+ itemId,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) log.error('Shopping cart data failure', data.error);
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
    if(this.instance.disabled) return alert(shoppingCartPluginL10n.waitLastRequest);
    if( confirm(shoppingCartPluginL10n.removeItem) ) this.instance.removeItem(itemId);
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
    if(this.instance.disabled) return alert(shoppingCartPluginL10n.waitLastRequest);
    link.parentNode.parentNode.cartObj.toggle();
  }
  Cart.prototype.toggle = function() {
    this.visible ? this.hide(true) : this.show(true);
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
    var total = 0;
    var currency, sep = "";
    for( var itemId in this.items ) {
      var item = this.items[itemId];
      if( item.price ) {
        currency = item.price.replace(/^([^0-9]+).*$/, "$1");
        sep = item.price.charAt(item.price.length-3);
        var price = item.price.replace(/[^0-9]/g,"");
        total += item.quantity * parseFloat(price);
      }
    }
    total = Math.round(total).toString().replace(/(..)$/, sep+"$1")
    $(".cart-total b", this.cartElem).text( ( (total!=0) ? currency+" "+total : "---" ) );
  }

  Cart.clean = function(link) {
    if(this.instance.disabled) return alert(shoppingCartPluginL10n.waitLastRequest);
    if( confirm(shoppingCartPluginL10n.cleanCart) ) link.parentNode.parentNode.parentNode.cartObj.clean();
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
          $(me.cartElem).slideUp(500, function() {
            $(me.itemsBox).empty();
            me.hide();
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
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) display_notice(data.error.message);
        else {
          me.clean();
          display_notice(data.message);
        }
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        log.error('Send request - HTTP '+status, errorThrown);
      },
      complete: function() {
        noosfero.modal.close();
      }
    });
  }


  $(window).bind('beforeunload', function(){
    log('Page unload.');
    Cart.unloadingPage = true;
  });

  $(function(){

    $.ajax({
      url: "/plugin/shopping_cart/get",
      dataType: 'json',
      success: function(data) {
        new Cart(data);
        $('.cart-add-item').button({ icons: { primary: 'ui-icon-cart'} })
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        // Give some time to register page unload.
        setTimeout(function() {
          // page unload is not our problem.
          if (Cart.unloadingPage) {
            log('Page unload before cart load.');
          } else {
            log.error('Error getting shopping cart - HTTP '+status, errorThrown);
            if ( confirm(shoppingCartPluginL10n.getProblemConfirmReload) ) {
              document.location.reload();
            }
          }
        }, 100);
      }
    });
  });

})(jQuery);
