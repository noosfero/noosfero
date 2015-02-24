jQuery(function($) {

$("#usp_id_field").observe_field(1, function(){
  var me=this;
  $('#usp-id-invalid').hide();
  $(this).addClass('checking').removeClass('validated');
  $(this.parentNode).addClass('checking');
  $('#usp-id-checking').show();
  $.getJSON('/plugin/stoa/check_usp_id?usp_id='+me.value,
    function(data){
      $('#usp-id-checking').hide();
      if(data.exists) {
        $('#usp-id-invalid').hide();
        $.getJSON('/plugin/stoa/check_cpf?usp_id='+me.value,
          function(data){
            if(data.exists){
              $('#signup-birth-date').hide();
              $('#signup-cpf').show();
              $('#confirmation_field').remove();
              $('<input id="confirmation_field" type="hidden" value="cpf" name="confirmation_field">').insertAfter('#usp_id_field');
            }
            else {
              $('#signup-cpf').hide();
              $('#signup-birth-date').show();
              $('#confirmation_field').remove();
              $('<input id="confirmation_field" type="hidden" value="birth_date" name="confirmation_field">').insertAfter('#usp_id_field');
            }
            $('#signup-form .submit').attr('disabled', false);
            $(me).removeClass('checking').addClass('validated');
            $(me.parentNode).removeClass('checking');
          });
      }
      else {
        $(me).removeClass('checking');
        $(me.parentNode).removeClass('checking');
        if(me.value) {
          $('#signup-form .submit').attr('disabled', true);
          $(me).addClass('invalid');
          $('#profile-data #usp_id_field').parent().addClass('fieldWithErrors')
          $('#usp-id-invalid').show();
        }
        else {
          $('#signup-form .submit').attr('disabled', false);
          $(me).removeClass('invalid');
          $('#profile-data #usp_id_field').parent().removeClass('fieldWithErrors')
          $(me).removeClass('validated');
        }
        $('#signup-birth-date').hide();
        $('#signup-cpf').hide();
      }
      if(data.error) displayValidationUspIdError(data.error);
    }
  );
});
});

function displayValidationUspIdError(error){
  noosfero.modal.html('<h2>'+error.message+'</h2>'+error.backtrace.join("<br />"), {
    height: "80%",
    width:  "70%"
  });
}

jQuery('#usp_id_field').focus(function() { jQuery('#usp-id-balloon').fadeIn('slow'); });
jQuery('#usp_id_field').blur(function() { jQuery('#usp-id-balloon').fadeOut('slow'); });

jQuery('#signup-birth-date #birth_date').focus(function() { jQuery('#usp-birth-date-balloon').fadeIn('slow'); });
jQuery('#signup-birth-date #birth_date').blur(function() { jQuery('#usp-birth-date-balloon').fadeOut('slow'); });

jQuery('#signup-cpf #cpf').focus(function() { jQuery('#usp-cpf-balloon').fadeIn('slow'); });
jQuery('#signup-cpf #cpf').blur(function() { jQuery('#usp-cpf-balloon').fadeOut('slow'); });

jQuery('#signup-birth-date #birth_date, #signup-cpf #cpf').each(function() {
  jQuery(this).bind('blur', function() {
  if (jQuery(this).val() == '') {
    jQuery(this).removeClass('validated');
  }
  else jQuery(this).addClass('validated');
  });
});
