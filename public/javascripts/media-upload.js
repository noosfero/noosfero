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
