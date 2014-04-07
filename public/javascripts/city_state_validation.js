(function($){
  autoCompleteStateCity($);
  $('[id$="_country"]').change(function(){
    autoCompleteStateCity($);
  })
})(jQuery);

function autoCompleteStateCity($) {
  var country_selected = $('[id$="_country"] option:selected').val()
  if(country_selected == "BR")
  {
    $('#state_field').autocomplete({
      source : function(request, response){
        $.ajax({
          type: "GET",
          url: '/account/search_state',
          data: {state_name: request.term},
          success: function(result){
            response(result);
          },
          error: function(ajax, stat, errorThrown) {
            console.log('Link not found : ' + errorThrown);
          }
       });
      },

      minLength: 3
    });

    $('#city_field').autocomplete({
      source : function(request, response){
        $.ajax({
          type: "GET",
          url: '/account/search_cities',
          data: {city_name: request.term, state_name: $("#state_field").val()},
          success: function(result){
            response(result);
          },
          error: function(ajax, stat, errorThrown) {
            console.log('Link not found : ' + errorThrown);
          }
        });
      },

      minLength: 3
    });
  }
  else
  {
    if ($('#state_field').data('autocomplete')) {
      $('#state_field').autocomplete("destroy");
      $('#state_field').removeData('autocomplete');
    }

    if ($('#city_field').data('autocomplete')) {
      $('#city_field').autocomplete("destroy");
      $('#city_field').removeData('autocomplete');
    }
  }
}
