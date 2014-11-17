var file_id = 1;

jQuery('.view-all-media').on('click', '.pagination a', function(event) {
  jQuery.ajax({
    url: this.href,
    beforeSend: function(){jQuery('.view-all-media').addClass('fetching')},
    complete: function() {jQuery('.view-all-media').removeClass('fetching')},
    dataType: 'script'
  });
  return false;
});

jQuery('#file').fileupload({
  add: function(e, data){
    data.files[0].id = file_id;
    file_id++;
    data.context = jQuery(tmpl("template-upload", data.files[0]));
    jQuery('#media-upload-form').append(data.context);
    data.submit();
  },
  progress: function (e, data) {
    if (jQuery('#hide-uploads').data('bootstraped') == false) {
      jQuery('#hide-uploads').show();
      jQuery('#hide-uploads').data('bootstraped', true);
    }
    if (data.context) {
      progress = parseInt(data.loaded / data.total * 100, 10);
      data.context.find('.bar').css('width', progress + '%');
      data.context.find('.percentage').text(progress + '%');
    }
  },
  fail: function(e, data){
    var file_id = '#file-'+data.files[0].id;
    jQuery(file_id).find('.progress .bar').addClass('error');
    jQuery(file_id).append("<div class='error-message'>" + data.jqXHR.responseText + "</div>")
  }
});

jQuery('#hide-uploads').click(function(){
  jQuery('#hide-uploads').hide();
  jQuery('#show-uploads').show();
  jQuery('.upload').slideUp();
  return false;
});

jQuery('#show-uploads').click(function(){
  jQuery('#hide-uploads').show();
  jQuery('#show-uploads').hide();
  jQuery('.upload').slideDown();
  return false;
});

function loadPublishedMedia() {
  var parent_id = jQuery('#published-media #parent_id').val();
  var q = jQuery('#published-media #q').val();
  var url = jQuery('#published-media').data('url');

  jQuery('#published-media .items').addClass('fetching');
  jQuery.ajax({
    url: url,
    data: {'parent_id': parent_id, 'q': q},
    dataType: 'html',
    success: function(response) {
      jQuery("#published-media .items").html(response);
      jQuery('#published-media .items').removeClass('fetching');
      updateViewAllLinks();
    },
    error: function(response, textStatus, xhr) {
      console.log(response);
      console.log(textStatus);
    }
  });
}

function updateViewAllLinks() {
  var parent_id = jQuery('#published-media #parent_id').val();
  var q = jQuery('#published-media #q').val();
  jQuery('#published-media .view-all').each(function(){
    var key = jQuery(this).data('key');
    var params = {parent_id: parent_id, q: q, key: key}
    var href = jQuery(this).attr('href');
    href = href.replace(/\?.*/, '?'+jQuery.param(params));
    jQuery(this).attr('href', href);
  });
}

jQuery('#published-media #parent_id').change(function(){ loadPublishedMedia() });

jQuery("#published-media #q").typeWatch({
  callback: function (value) { loadPublishedMedia() },
  wait: 750,
  highlight: true,
  captureLength: 2
});

jQuery("#published-media #q").bind('notext', function(){ loadPublishedMedia() });

jQuery("#new-folder-dialog").submit(function( event ) {
  var name = jQuery('#new_folder').val();
  var parent_id = jQuery("#new-folder-dialog #parent_id").val();
  jQuery.ajax({
    url: this.action,
    type: 'POST',
    data: {
      'parent_id': parent_id,
      'article': {'name': name, 'published': true},
      'type': jQuery('input[name=folder_type]:checked').val() },
    dataType: 'json',
    beforeSend: function(){jQuery("#new-folder-dialog").addClass('fetching')},
    success: function(response) {
      var option_selected = "<option value='"+ response.id +"' selected='selected'>"+ response.full_name +"</options>"
      var option = "<option value='"+ response.id +"'>"+ response.full_name +"</options>"
      jQuery('#media-upload-form #parent_id').append(option_selected);
      jQuery('#published-media #parent_id').append(option);
      jQuery('#new_folder').val('');
    },
    error: function(response, textStatus, xhr) {
      console.log(response);
      console.log(textStatus);
    },
    complete: function(response){
      jQuery("#new-folder-dialog").removeClass('fetching');
      jQuery("#new-folder-dialog").dialog('close');
    }
  });
  return false;
});

jQuery('.text-editor-sidebar .header .icon-vertical-toggle').click(function(){
  jQuery('#content').toggleClass('show-media-panel');
  return false;
});

jQuery('#new-folder-button').click(function(){
  jQuery('#new-folder-dialog').dialog({modal: true});
  return false;
});
