
orders = {

  locales: {
    noneSelected: '',
  },

  order: {

    reload: function(context, url) {
      var order = $(context).parents('.order-view')

      loading_overlay.show(order)
      $.getScript(url, function () {
        loading_overlay.hide(order)
      })
    },

    submit: function(form) {
      var order = $(form).parents('.order-view')

      $(form).ajaxSubmit({dataType: 'script',
        beforeSubmit: function(){ loading_overlay.show(order) },
        success: function(){ loading_overlay.hide(order) },
      })

      return false
    },

  },

  item: {

    edit: function () {
    },

    edit_quantity: function (item) {
      item = $(item);
      toggle_edit.edit(item);

      var quantity = item.find('.quantity input');
      quantity.focus();
    },

    // keydown prevents form submit, keyup don't
    quantity_keydown: function(context, event) {
      if (event.keyCode == 13) {
        var item = $(context).parents('.item');
        item.find('.more .submit').get(0).onclick();

        event.preventDefault();
        return false;
      }
    },

    admin_add: {
      search_url: null,
      add_url: null,
      source: null,

      load: function (id) {
        var self = this
        var input = $('#order-row-'+id+' .order-product-add .add-input')
        this.source = new Bloodhound({
          datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
          queryTokenizer: Bloodhound.tokenizers.whitespace,
          remote: this.search_url+'&query=%QUERY',
        })
        this.source.initialize()

        input.typeahead({
          minLength: 2, highlight: true,
        }, {
          displayKey: 'label',
          source: this.source.ttAdapter(),
        }).on('typeahead:selected', function(e, item) {
          input.val('')
          $.post(self.add_url, {product_id: item.value}, function(data) {
          })
        })
      },
    },

    admin_remove: function(context, url) {
      var container = $(context).parents('.order-items-container');
      var item = $(context).parents('.item');
      var quantity = item.find('.quantity input');
      quantity.val('0')
      this.submit(context, url)
    },

    submit: function(context, url) {
      var container = $(context).parents('.order-items-container');
      var item = $(context).parents('.item');
      var quantity = item.find('.quantity input');
      var data = {}
      data[quantity[0].name] = quantity.val()

      loading_overlay.show(container);
      $.post(url, data, function(){}, 'script');
    },
  },

  admin: {

    toggle_edit: function () {
      sortable_table.edit_arrow_toggle(toggle_edit.editing(), toggle_edit.isEditing());
    },

    load_edit: function(order, url) {
      var edit = $(order).find('.box-edit')
      edit.load(url, function() {
        edit.removeClass('loading')
      });
      $(order).attr('onclick', '')
    },

    select: {
      all: function() {
        $('.order #order_ids_').attr('checked', true)
      },
      none: function() {
        $('.order #order_ids_').attr('checked', false)
      },

      selection: function() {
        return $('.order #order_ids_:checked').parents('.order')
      },

      report: function(url) {
        var ids = this.selection().map(function (i, el) { return $(el).attr('data-id') }).toArray();
        if (ids.length === 0) {
          alert(orders.locales.noneSelected)
          return
        }
        window.location.href = url + '&' + $.param({ids: ids})
      },

    },
  },

  setOrderMaxHeight: function()
  {
    ordersH = $(window).height();
    ordersH -= $('#cirandas-top-bar').outerHeight()
    ordersH -= $('.order-view form > .actions').outerHeight(true)
    $('.order-view .order-data').css('max-height', ordersH);
  },

  daterangepicker: {

    init: function(rangeSelector, _options) {
      var options = $.extend({}, orders.daterangepicker.defaultOptions, _options);
      var rangeField = $(rangeSelector)
      var container = rangeField.parents('.daterangepicker-field-container')
      var startField = container.find('input[data-field=start]')
      var endField = container.find('input[data-field=end]')

      var startDate = moment(startField.val(), moment.ISO_8601).format(options.format)
      var endDate = moment(endField.val(), moment.ISO_8601).format(options.format)
      var rangeValue = startDate+options.separator+endDate
      rangeField.val(rangeValue)

      rangeField.daterangepicker(options)
      .on('apply.daterangepicker change', function(ev, picker) {
        picker = rangeField.data('daterangepicker')
        startField.val(picker.startDate.toDate().toISOString())
        endField.val(picker.endDate.toDate().toISOString())
      });
    },
  },
};

$(document).ready(orders.setOrderMaxHeight);
$(window).resize(orders.setOrderMaxHeight);
$('#order_supplier_delivery_id').change(orders.setOrderMaxHeight);

