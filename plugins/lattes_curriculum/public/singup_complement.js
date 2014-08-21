jQuery(function($){
  $(document).ready(function(){
    $('#lattes_id_field').blur(function(){
      var value = this.value
    })

    $('#lattes_id_field').focus(function(){
      $('#lattes-id-balloon').fadeIn('slow')
    })

    $('#lattes_id_field').blur(function(){
      $('#lattes-id-balloon').fadeOut('slow')
    })
  })
})