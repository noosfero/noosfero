(function($) {
  $(document).ready( function() {
    // Moves the extra content inside the search form
    $("#facets-toggle").appendTo($(".profile-search-block form.search_form"))

    // Collapse filters if it's the profile search page
    $('.controller-profile_search').bind('DOMSubtreeModified', function() {
      $('#facets-toggle').removeClass('toggle-hidden');
    })

    $('.action-profile_search-index .profile-search-block').on('click', '#toggle-filters', function() {
      toggleFacets();
    });

    $('.profile-search-block #toggle-filters').not('.action-profile_search-index .profile-search-block #toggle-filters').on('click', function() {
      $(location).attr('href', $(".profile-search-block .search_form").attr('action'));
    })
  });

  function toggleFacets() {
    $('#facets-wrapper').toggle('slow')
    $('#facets-toggle').toggleClass('toggle-hidden')
  }
})(jQuery);
