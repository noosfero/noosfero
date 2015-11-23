table_filter = {

  form: function() {
    return $('#filter form')
  },

  pagination: {
    init: function(text) {
      pagination.infiniteScroll(text, {load: this.load});
    },

    load: function (url) {
      var page = /page=([^&$]+)\&?/.exec(url)[1]
      var form = table_filter.form().get(0)

      form.elements.page.value = page
      var url = form.action + '?' + $(form).serialize()
      form.elements.page.value = ''

      $.get(url, function(data) {
        $('.table-content').find('.pagination').remove()
        $('.table-content').append(data)
        pagination.loading = false
      })
    },
  },
};
