jQuery("#usp_id_field").observe_field(1, function(){
  var me=this;
  jQuery(this).addClass('checking').removeClass('validated');
  jQuery.getJSON('/plugin/stoa/check_usp_id?usp_id='+me.value,
    function(data){
      if(data.exists) {
        jQuery.getJSON('/plugin/stoa/check_cpf?usp_id='+me.value,
          function(data){
            if(data.exists){
              jQuery('#signup-birth-date').hide();
              jQuery('#signup-cpf').show();
              jQuery('#confirmation_field').remove();
              jQuery('#signup-form').append('<input id="confirmation_field" type="hidden" value="cpf" name="confirmation_field">')
            }
            else {
              jQuery('#signup-cpf').hide();
              jQuery('#signup-birth-date').show();
              jQuery('#confirmation_field').remove();
              jQuery('#signup-form').append('<input id="confirmation_field" type="hidden" value="birth_date" name="confirmation_field">')
            }
        jQuery('#signup-form .submit').attr('disabled', false);
        jQuery(me).removeClass('checking').addClass('validated');
          });
      }
      else {
        jQuery('#signup-form .submit').attr('disabled', true);
        jQuery('#signup-birth-date').hide();
        jQuery('#signup-cpf').hide();
        jQuery(me).removeClass('checking').addClass('invalid');
      }
      if(data.error) displayValidationUspIdError(data.error);
    }
);
});

function displayValidationUspIdError(error){
  jQuery.colorbox({html: '<h2>'+error.message+'</h2>'+error.backtrace.join("<br />"),
    height: "80%",
    width:  "70%" });
}

