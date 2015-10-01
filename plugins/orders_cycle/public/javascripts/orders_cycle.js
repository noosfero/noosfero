
orders_cycle = {

  cycle: {

    edit: {
      openingMessage: {
        onKeyup: function(textArea) {
          textArea = $(textArea)
          var checked = textArea.val() ? true : false;
          var checkBox = textArea.parents('#cycle-new-mail').find('input[type=checkbox]')
          checkBox.prop('checked', checked)
        },
      },
    },

    products: {
      load_url: null,

      load: function () {
        $.get(orders_cycle.cycle.products.load_url, function(data) {
          if (data.length > 10)
            $('#cycle-products .table').html(data)
          else
            setTimeout(orders_cycle.cycle.products.load, 5*1000);
        });

      },
    },
  },

  /* ----- cycle ----- */

  in_cycle_order_toggle: function (context) {
    container = $(context).hasClass('cycle-orders') ? $(context) : $(context).parents('.cycle-orders');
    container.toggleClass('show');
    container.find('.order-content').toggle();
    sortable_table.edit_arrow_toggle(container);
  },

  /* ----- order ----- */

  order: {

    load: function() {
      $('html').click(function(e) {
        $('.popover').remove()
      })
    },

    product: {
      include_message: '',
      order_id: 0,
      redirect_after_include: '',
      add_url: '',
      remove_url: '',
      balloon_url: '',

      load: function (id, state) {
        var product = $('#cycle-product-'+id);
        product.toggleClass('in-order', state);
        product.find('input').get(0).checked = state;
        toggle_edit.value_row.reload();
        return product;
      },

      showMore: function (url) {
        $.get(url, function (data) {
          var newProducts = $(data).filter('#cycle-products').find('.table-content').children()
          $('.pagination').replaceWith(newProducts)
          pagination.loading = false
        })
      },

      click: function (event, id) {
        // was this a child click?
        if (event != null && event.target != this && event.target.onclick)
          return;

        var product = $('#cycle-product-'+id);
        if (! product.hasClass('editable'))
          return;

        var state = !product.hasClass('in-order');
        if (state == true)
          this.add(id);
        else
          this.remove(id);
        product.find('input').get(0).checked = state;
      },

      setEditable: function (editable) {
        $('.order-cycle-product').toggleClass('editable', editable)
        if (editable)
          $('.order-cycle-product #product_ids_').removeAttr('disabled')
        else
          $('.order-cycle-product #product_ids_').attr('disabled', 'disabled')
      },

      add: function (id) {
        var product = this.load(id, true);

        if (this.include_message)
          alert(this.include_message);

        loading_overlay.show(product);
        $.post(this.add_url, {order_id: this.order_id, redirect: this.redirect_after_include, offered_product_id: id}, function () {
          loading_overlay.hide(product);
        }, 'script');
      },
      remove: function (id) {
        var product = this.load(id, false);

        loading_overlay.show(product);
        $.post(this.remove_url, {id: id, order_id: this.order_id}, function () {
          loading_overlay.hide(product);
        }, 'script');
      },

      supplier: {
        balloon_url: '',

        balloon: function (id) {
          var product = $('#cycle-product-'+id)
          var target = product.find('.supplier')
          var supplier_id = product.attr('supplier-id')
          $.get(this.balloon_url+'/'+supplier_id, function(data) {
            var html = $(data)
            var title = orders_cycle.order.product.balloon_title(html)
            // use container to avoid conflict with row click
            var options = {html: true, content: html, container: 'body', title: title}
            target.popover(options).popover('show')
          })
        },
      },

      balloon: function (id) {
        var product = $('#cycle-product-'+id);
        var target = product.find('.product');
        $.get(this.balloon_url+'/'+id, function(data) {
          var html = $(data)
          var title = orders_cycle.order.product.balloon_title(html)
          // use container to avoid conflict with row click
          var options = {html: true, content: html, container: 'body', title: title}
          target.popover(options).popover('show')
        })
      },

      balloon_title: function(content) {
        var titleElement = $(content).find('.popover-title')
        var title = titleElement.html()
        titleElement.hide()
        return title
      },
    }, // product
  }, // order

  /* ----- cycle editions ----- */

  offered_product: {

    pmsync: function (context, to_price) {
      p = $(context).parents('.cycle-product .box-edit');
      margin = p.find('#product_margin_percentage');
      price = p.find('#product_price');
      buy_price = p.find('#product_buy_price');
      original_price = p.find('#product_original_price');
      base_price = unlocalize_currency(buy_price.val()) ? buy_price : original_price;

      if (to_price)
        suppliers.price.calculate(price, margin, base_price);
      else
        suppliers.margin.calculate(margin, price, base_price);
    },

    edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
    },
  },

  /* ----- toggle edit ----- */

  cycle_mail_message_toggle: function () {
    if ($('#cycle-new-mail-send').prop('checked')) {
      $('#cycle-new-mail').removeClass('disabled');
      $('#cycle-new-mail textarea').removeAttr('disabled');
    } else {
      $('#cycle-new-mail').addClass('disabled');
      $('#cycle-new-mail textarea').attr('disabled', true);
    }
  },

  ajaxifyPagination: function(selector) {
    $(selector).find(".pagination a").click(function() {
      loading_overlay.show(selector);
      $.ajax({
        type: "GET",
        url: $(this).attr("href"),
        dataType: "script"
      });
      return false;
    });
  },

  toggleCancelledOrders: function () {
    $('.consumers-coop #show-cancelled-orders a').toggle();
    $('.consumers-coop #hide-cancelled-orders a').toggle();
    $('.consumers-coop .consumer-order.cancelled').not('.comsumer-order.active-order').toggle();
  },

};
