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

})();

// Public

customForms = {
  // Click in a poll radio will update "checked" class in all related labels
  updateRadioGroupClass: function (label) {
    console.log($("input", label));
    $("label", label.parentNode).removeClass("checked");
    $(label).toggleClass("checked", $("input", label).prop("checked"));
  },
  // Click in a poll checkbox will update "checked" class in its label
  updateCBoxLabelClass: function(label) {
    console.log( 'LABEL', label )
    console.log( 'INPUT', $("input[type=checkbox]", label) )
    $(label).toggleClass("checked", $("input[type=checkbox]", label).prop("checked"));
  }
}
