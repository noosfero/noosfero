product_categories = {

  autocomplete: {
    search_url: '',
    select_url: '',

    load: function(elem) {
      elem = jQuery(elem)

      elem.autocomplete({
        minLength: 3,
        selectFirst: true,

        //define callback to retrieve results
        source: function(req, add) {
          //pass request to server
          //The alt attribute contains the wordpress callback action
          var params = { term: req.term };
          jQuery.getJSON(product_categories.autocomplete.search_url, params, function(data) {
            add(data);
          });
        },

        focus: function( event, ui ) {
          jQuery(this).val(ui.item.label);
          return false;
        },

        select: function(e, ui) {
          jQuery('#categories-container').load(product_categories.autocomplete.select_url, {category_id: ui.item.value})

          jQuery(this).val("")
        },

      });

    },
  },

};
