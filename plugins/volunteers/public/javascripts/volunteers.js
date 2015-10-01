volunteers = {

  periods: {
    load: function() {
      $('#volunteers-periods .period').each(function() {
        volunteers.periods.applyDaterangepicker(this)
      })
      $('#period-new input').prop('disabled', true)
    },

    new: function() {
      var period = $('#volunteers-periods-template').html()
      period = period.replace(/_new_/g, new Date().getTime())
      period = $(period)
      period.find('input').prop('disabled', false)
      this.applyDaterangepicker(period)
      return period
    },

    add: function() {
      $('.periods').append(this.new())
    },

    remove: function(link) {
      link = $(link)
      var period = link.parents('.period')
      period.find('input[name*=_destroy]').prop('value', '1')
      period.hide()
    },

    applyDaterangepicker: function(period) {
      orders.daterangepicker.init($(period).find('.daterangepicker-field'))
    },

  },

  assignments: {
    toggle: function(period) {
      period = $(period)
      $.get(period.attr('data-toggle-url'), function(data) {
        $(period).replaceWith(data)
      })
    },

  },

};
