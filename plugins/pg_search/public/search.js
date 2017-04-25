(function($) {
  $('#facets input[type=checkbox]').live('change', function() {
    $('form.search_form').submit();
    return false;
  });

  $('#facets .period input').live('change', function() {
    $('form.search_form').submit();
    return false;
  });

  // Facet See all
  $('.facet .see-all').live('click', function() {
    var id = $(this).data('facet');
    $('#see-all-' + id).toggle();
    return false;
  });

  // Facet Clear
  $('.facet .clear-facet').live('click', function() {
    var id = $(this).data('facet');
    var update = $('#'+ id +' input[type="checkbox"]:checked').length > 0;
    $('#'+ id +' input[type="checkbox"]').attr('checked', false);
    $('#'+ id +' .facet-refine').val('').trigger('keyup');
    if(update) $('form.search_form').submit();
    return false;
  });

  // Facet Refine

  $('.facet-refine').live('keypress', function(ev) {
    if(ev.key == 'Enter') return false;
  });

  $('.facet-refine').live('keyup', function(ev) {
    var query = this.value.toLowerCase();
    var block = $(this).parent().children('.facets-block');
    block.children().each(function(index, element) {
      if($('label', element).text().toLowerCase().indexOf(query) >= 0)
        element.style.display = 'block';
      else
        element.style.display = 'none';
    });
  });
})(jQuery);

