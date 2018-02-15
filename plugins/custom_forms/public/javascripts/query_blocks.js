(function() {
  function markOverflownBlocks() {
    var elements = $('.block .form-item .form-description')
    elements.each(function(index) {
      if (this.offsetHeight < this.scrollHeight) {
        $(this).addClass('overflown')
      }
    })
  }

  $(document).ready(function() {
    markOverflownBlocks()
  })
})()
