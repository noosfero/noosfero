
suppliers = {

  filter: {
    form: function() {
      return table_filter.form()
    },

    apply: function() {
      this.form().submit()
    },

  },

  add_link: function () {
    if (toggle_edit.isEditing())
      toggle_edit.value_row.toggle_edit();

    var supplier_add = $('#supplier-add');
    toggle_edit.setEditing(supplier_add);
    toggle_edit.value_row.toggle_edit();
  },

  toggle_edit: function () {
    if (toggle_edit.editing().is('#supplier-add'))
      toggle_edit.editing().toggle(toggle_edit.isEditing());
    toggle_edit.editing().find('.box-view').toggle(!toggle_edit.isEditing());
    toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing());
  },

  add: {
    supplier_added: function () {
      $('#results').html('');
    },
    create_dummy: function () {
      $('#find-enterprise, #create-dummy, #create-dummy .box-edit').toggle();
    },

    search: function (input) {
      query = $(input).val();
      if (query.length < 3)
        return;
      input.form.onsubmit();
    },
  },

  // core uses (future product plugin)
  product: {

    pmsync: function (to_price) {
      var margin_input = $('#product_margin_percentage')
      var price_input = $('#product_price')
      var base_price_input = $('#product_supplier_product_attributes_price')

      if (to_price)
        suppliers.price.calculate(price_input, margin_input, base_price_input)
      else
        suppliers.margin.calculate(margin_input, price_input, base_price_input)
    },

    updateBasePrice: function () {
      this.pmsync(this)
    },
  },

  our_product: {

    toggle_edit: function () {
      toggle_edit.editing().find('.box-edit').toggle(toggle_edit.isEditing())
    },

    default_change: function (event) {
      var block = $(this).parents('.block')
      var nonDefaults = block.find('div[data-non-defaults]')
      nonDefaults.toggle(!this.checked)
      nonDefaults.find('input,select,textarea').prop('disabled', this.checked)
    },

    load: function(id) {
      $('#our-product-'+id+' div[data-default-toggle] input').change(suppliers.our_product.default_change).change();
    },

    pmsync: function (context, to_price) {
      var p = $(context).parents('.our-product')
      var margin_input = p.find('.product-margin-percentage')
      var price_input = p.find('.product-price')
      var buy_price_input = p.find('.product-base-price')

      if (to_price)
        suppliers.price.calculate(price_input, margin_input, buy_price_input)
      else
        suppliers.margin.calculate(margin_input, price_input, buy_price_input)
    },

    select: {
      all: function() {
        $('.our-product #product_ids_').attr('checked', true)
      },
      none: function() {
        $('.our-product #product_ids_').attr('checked', false)
      },

      activate: function(state) {
        var selection = $('.our-product #product_ids_:checked').parents('.our-product')
        selection.find('.available input[type=checkbox]').each(function() {
          this.checked = state
          $(this.form).submit()
        });
      },

    },

    import: {
      confirmRemoveAll: function(checkbox, text) {
        if (checkbox.checked && !confirm(text))
          checkbox.checked = false
      },
    },
  },

  basket: {
    searchUrl: null,
    addUrl: null,
    removeUrl: null,

    remove: function (id) {
      var self = this
      $.ajax(self.removeUrl, {method: 'DELETE',
       data: {aggregate_id: id},
       success: function(data) {
        self.reload(data)
       },
      })
    },

    reload: function (data) {
      $('#product-basket').html(data)
      $('#basket-add').focus()
    },

    load: function () {
      var self = this
      var input = $('#basket-add')

      self.source = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote: this.searchUrl+'?query=%QUERY',
      })
      self.source.initialize()

      input.typeahead({
        minLength: 2, highlight: true,
      }, {
        displayKey: 'label',
        source: this.source.ttAdapter(),
      }).on('typeahead:selected', function(e, item) {
        input.val('')
        $.post(self.addUrl, {aggregate_id: item.value}, function(data) {
          self.reload(data)
        })
      })
    },
  },

  price: {

    calculate: function (price_input, margin_input, base_price_input) {
      var price = unlocalize_currency($(price_input).val());
      var base_price = unlocalize_currency($(base_price_input).val());
      var margin = unlocalize_currency($(margin_input).val());

      var value = base_price + (margin / 100) * base_price;
      if (isNaN(value))
        value = unlocalize_currency(base_price_input.val());
      $(price_input).val(value);
    },
  },

  margin: {

    calculate: function (margin_input, price_input, base_price_input) {
      var price = unlocalize_currency($(price_input).val());
      var base_price = unlocalize_currency($(base_price_input).val());
      var margin = unlocalize_currency($(margin_input).val());

      var value = ((price - base_price) / base_price ) * 100;
      value = !isFinite(value) ? 0.0 : value;
      $(margin_input).val(value);
    },
  },

};

