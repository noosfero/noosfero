jQuery('#file').fileupload({
  add: function(e, data){
    data.context = jQuery(tmpl("template-upload", data.files[0]));
    jQuery('#media-upload-form').append(data.context);
    data.submit();
  },
  progress: function (e, data) {
    if (data.context) {
      progress = parseInt(data.loaded / data.total * 100, 10);
      data.context.find('.bar').css('width', progress + '%');
      data.context.find('.percentage').text(progress + '%');
    }
  }
});

jQuery('#published-media #parent_id').change(function(){
  value = jQuery(this).val();
  if(value == '')
    value = 'recent-media'
  selector = '#published-media #'+value

  if (jQuery(selector).length > 0){
    jQuery('#published-media .items').hide();
    jQuery(selector).show();
  } else {
    jQuery('#published-media').addClass('fetching');
    url = jQuery(this).data('url');
    jQuery.ajax({
      url: url,
      data: {"parent_id":value},
      dataType: 'html',
      success: function(response) {
        jQuery('#published-media .items').hide();
        jQuery("#published-media").append('<div id="'+ value +'" class="items">' + response + '</div>');
        jQuery('#published-media').removeClass('fetching');
      },
      error: function(response, textStatus, xhr) {
        console.log(response);
        console.log(textStatus);
      }
    });
  }
});
