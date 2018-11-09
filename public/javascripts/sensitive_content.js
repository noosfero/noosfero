sensitive_content = {

  current_page: '#',
  history: [],

  initialize: function(element) {
    this.current_page = $(element).attr('href')
    this.history = []
  },

  addHistory: function(element) {
    this.history.push(this.current_page)
    this.current_page = $(element).attr('href')
  },

  backHistory: function(element, loadCallback) {
    this.current_page = this.history.pop()
    if(this.history.length == 0) {
        if(this.current_page.includes('?')) {
            loadCallback(this.current_page + '&back=true')
        } else {
            loadCallback(this.current_page + '?back=true')
        }
    } else {
        loadCallback(this.current_page)
    }
  }
}

$( document ).ready(function() {

    $('#new-sensitive-content .option-back').live('click', function(event) {
        event.stopPropagation()
        sensitive_content.backHistory(this, noosfero.modal.loadPage)
    })

    $('a.initialize-sensitive-history').live('click', function(event) {
        sensitive_content.initialize(this)
    })

    $('#new-sensitive-content a.add-sensitive-history').live('click', function(event) {
        sensitive_content.addHistory(this)
    })
})
