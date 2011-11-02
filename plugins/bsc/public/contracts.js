var BSCContracts = {};

(function($){
  BSCContracts.onDelete = function(item){
    $('.token-input-dropdown').hide();
    $('#bsc-plugin-row-'+item.sale_id.toString()).remove();
    BSCContracts.updateTotal();
  };
    
  BSCContracts.onAdd = function(item){
    var quantity = $('#bsc-plugin-sale-'+item.sale_id.toString()+'-quantity');
    var price = $('#bsc-plugin-sale-'+item.sale_id.toString()+'-price');
    quantity.addClass('required');
    price.addClass('required');
    quantity.val(1);
    price.val(item.product_price);
    BSCContracts.updateTotal();
  };

  BSCContracts.newID = function(){
    if ( !this.idNum ) this.idNum = 0;
    return this.idNum++;
  };

  BSCContracts.newProductLine = function(item){
    var id = this.newID();
    var tr = $('<tr class="bsc-plugin-sales-product" id="bsc-plugin-row-'+id+'"></tr>');
    var tds = $('<td></td><td></td><td>'+this.currencyUnit+'</td>').appendTo(tr);
    var input = $('<input name="sales['+id+'][product_id]" class="search-product-field"/>').appendTo(tds[0]);
    var searchUrl = this.searchUrl
                        .replace('ENTERPRISES', $('#involved-enterprises').val())
                        .replace('SALE_ID', id)
                        .replace('ADDED_PRODUCTS', $.map($('.search-product-field'), function(item){return item.value}).join(',')); 
    var prePopulation = [];
    var quantity = '';
    var price = '';
    var required = '';
    if(item) {
      item.sale_id = id;
      prePopulation = [item];
      quantity = item.quantity;
      price = item.product_price;
      required = 'required';
    }
    var opts = $.extend( { prePopulate: prePopulation, queryParam: input[0].name }, this.tokenInputOptions );

    input.keydown(function(event){ if(event.keyCode == '13') return false })
         .tokenInput(searchUrl, opts);
    $('#bsc-plugin-contract-total-row').before(tr);
    $('<input id="bsc-plugin-sale-'+id+'-quantity" class="bsc-plugin-sales-quantity '+required+' digits" name="sales['+id+'][quantity]" align="center" size="7" value="'+quantity+'"/>').appendTo(tds[1]);
    $('<input id="bsc-plugin-sale-'+id+'-price" class="bsc-plugin-sales-price '+required+' number" name="sales['+id+'][price]" value="'+price+'"/>').appendTo(tds[2]);
  };

  BSCContracts.prePopulate = function(items){
    $(items).each(function(index, item){BSCContracts.newProductLine(item)});
  }

  BSCContracts.updateTotal = function(){
    var total = 0;
    var quantity = 0;
    var price = 0;
    $('.bsc-plugin-sales-product').each(function(index){
        quantity = $('#' + $(this).attr('id') + " .bsc-plugin-sales-quantity").val();
        price = $('#'+$(this).attr('id') + " .bsc-plugin-sales-price").val();
        total += quantity*price;
    });
    $('#bsc-plugin-sales-total-value').text(BSCContracts.currencyUnit+' '+total);
  }
  
  $(".bsc-plugin-sales-price, .bsc-plugin-sales-quantity").live('change', function(e){
    BSCContracts.updateTotal();
  });
  
  $("#bsc-plugin-add-new-product").click(function(){
    var last = $('.search-product-field:last');
    if(!last.val() && last.size() != 0){
      last.focus();
      return false;
    }
    var next_id = parseInt(last.attr('data-sale-id'))+1;
    var enterprises = $('#involved-enterprises').val().replace(/,/g,'-');
    BSCContracts.newProductLine();
    return false;
  });

})(jQuery);
