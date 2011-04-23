function Cart(config) {
  var $ = jQuery;
  Cart.instance = this; // this may be a list on the future;
  this.cartElem = $("#cart1")[0];
  this.cartElem.cartObj = this;
  this.contentBox = $("#cart1 .cart-content");
  this.itemsBox = $("#cart1 .cart-items");
  this.items = {};
  this.visible = false;
  if (config.hasProducts) {
    $(this.cartElem).show();
    this.enterprise = config.enterprise;
    this.listProducts();
  }
  $(".cart-buy", this.cartElem).button({ icons: { primary: 'ui-icon-cart'} });
}

(function($){

  Cart.prototype.listProducts = function() {
    var me = this;
    $.ajax({
      url: '/profile/'+ this.enterprise +'/plugins/shopping_cart/list',
      dataType: 'json',
      success: function(data, ststus, ajax){
        if ( !data.ok ) alert(data.error.message);
        else me.addToList(data, true);
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        alert('List cart items - HTTP '+status+': '+errorThrown);
      }
    });
  }

  Cart.prototype.addToList = function(data, clear) {
    if( clear ) this.itemsBox.empty();
    var me = this;
    for( var item,i=0; item=data.products[i]; i++ ) {
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
        ' <a href="remove:'+item.name+'" onclick="Cart.removeItem(\''+this.enterprise+'\', '+item.id+'); return false"' +
        ' class="button icon-delete"><span>remove</span></a>'
       ).appendTo(li);
      var input = $("input", li)[0];
      input.lastValue = input.value;
      input.itemId = item.id;
      input.ajustSize = function() {
        var len = this.value.toString().length;
        if(len > 2) len--;
        this.style.width = len+"em";
      };
      input.ajustSize();
      input.onchange = function() {
        me.updateQuantity(this, this.itemId, this.value);
      };
      document.location.href = "#"+liId;
      document.location.href = "#"+this.cartElem.id;
      history.go(-2);
      var liBg = li.css("background-color");
      li[0].style.backgroundColor = "#FF0";
      li.animate({ backgroundColor: liBg }, 1000);
    }
    if( !this.visible ) {
      this.contentBox.hide();
      this.show();
    }
  }

  Cart.prototype.updateQuantity = function(input, itemId, quantity) {
    quantity = parseInt(quantity);
    input.disabled = true;
    var originalBg = input.style.backgroundImage;
    input.style.backgroundImage = "url(/images/loading-small.gif)";
    var me = this;
    if( quantity == NaN ) return input.value = input.lastValue;
    $.ajax({
      url: '/profile/'+ this.enterprise +'/plugins/shopping_cart/update_quantity/'+ itemId +'?quantity='+ quantity,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) {
          alert(data.error.message);
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
        alert('Add item - HTTP '+status+': '+errorThrown);
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

  Cart.addItem = function(enterprise, itemId, link) {
    // on the future, the instance may be found by the enterprise identifier.
    link.intervalId = setInterval(function() {
      steps = ['w', 'n', 'e', 's'];
      if( !link.step || link.step==3 ) link.step = 0;
      link.step++;
      $(link).button({ icons: { primary: 'ui-icon-arrowrefresh-1-'+steps[link.step]}, disable: true })
    }, 100);
    var stopBtLoading = function() {
      clearInterval(link.intervalId);
      $(link).button({ icons: { primary: 'ui-icon-cart'}, disable: false });
    };
    this.instance.addItem(enterprise, itemId, stopBtLoading);
  }

  Cart.prototype.addItem = function(enterprise, itemId, callback) {
    if(!this.enterprise) {
      this.enterprise = enterprise;
      if( !this.visible ) $(this.cartElem).show();
    }
    var me = this;
    $.ajax({
      url: '/profile/'+ enterprise +'/plugins/shopping_cart/add/'+ itemId,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) alert(data.error.message);
        else me.addToList(data);
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        alert('Add item - HTTP '+status+': '+errorThrown);
      },
      complete: callback
    });
  }

  Cart.removeItem = function(enterprise, itemId) {
    var message = this.instance.cartElem.getAttribute('data-l10nRemoveItem');
    if( confirm(message) ) this.instance.removeItem(enterprise, itemId);
  }

  Cart.prototype.removeItem = function(enterprise, itemId) {
    if ($("li", this.itemsBox).size() < 2) return this.clean();
    var me = this;
    $.ajax({
      url: '/profile/'+ enterprise +'/plugins/shopping_cart/remove/'+ itemId,
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) alert(data.error.message);
        else me.removeFromList(data.product_id);
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        alert('Remove item - HTTP '+status+': '+errorThrown);
      }
    });
  }

  Cart.toggle = function(link) {
    link.parentNode.parentNode.cartObj.toggle();
  }
  Cart.prototype.toggle = function() {
    this.visible ? this.hide() : this.show();
  }

  Cart.prototype.show = function() {
    this.visible = true;
    this.contentBox.slideDown(500);
    $(".cart-toggle .str-show", this.cartElem).hide();
    $(".cart-toggle .str-hide", this.cartElem).show();

  }
  Cart.prototype.hide = function() {
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
    var message = this.instance.cartElem.getAttribute('data-l10nCleanCart');
    if( confirm(message) ) link.parentNode.parentNode.parentNode.cartObj.clean();
  }

  Cart.prototype.clean = function() {
    var me = this;
    $.ajax({
      url: '/profile/'+ me.enterprise +'/plugins/shopping_cart/clean',
      dataType: 'json',
      success: function(data, status, ajax){
        if ( !data.ok ) alert(data.error.message);
        else{
          me.items = {};
          $(me.cartElem).slideUp(500, function() {
            $(me.itemsBox).empty();
            me.hide();
            me.enterprise = null;
            me.updateTotal();
          });
        }
      },
      cache: false,
      error: function(ajax, status, errorThrown) {
        alert('Remove item - HTTP '+status+': '+errorThrown);
      }
    });
  }

  $(function(){
    $('.cart-add-item').button({ icons: { primary: 'ui-icon-cart'} })
  });

})(jQuery);
