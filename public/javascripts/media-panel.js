(function($) {
  "use strict";

  var file_id = 1;

  $('.view-all-media').on('click', '.pagination a', function(event) {
    $.ajax({
      url: this.href,
      beforeSend: function(){$('.view-all-media').addClass('fetching')},
      complete: function() {$('.view-all-media').removeClass('fetching')},
      dataType: 'script'
    });
    return false;
  });


  $('#file').fileupload({
    add: function(e, data){
      data.files[0].id = file_id;
      file_id++;
      data.context = $(tmpl("template-upload", data.files[0]));
      $('#media-upload-form').append(data.context);
      data.submit();
    },
    progress: function (e, data) {
      if ($('#hide-uploads').data('bootstraped') == false) {
        $('#hide-uploads').show();
        $('#hide-uploads').data('bootstraped', true);
      }
      if (data.context) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        data.context.find('.bar').css('width', progress + '%');
        data.context.find('.percentage').text(progress + '%');
      }
    },
    fail: function(e, data){
      var file_id = '#file-'+data.files[0].id;
      $(file_id).find('.progress .bar').addClass('error');
      $(file_id).append("<div class='error-message'>" + data.jqXHR.responseText + "</div>")
    }
  });


  $('#hide-uploads').click(function(){
    $('#hide-uploads').hide();
    $('#show-uploads').show();
    $('.upload').slideUp();
    return false;
  });


  $('#show-uploads').click(function(){
    $('#hide-uploads').show();
    $('#show-uploads').hide();
    $('.upload').slideDown();
    return false;
  });


  function loadPublishedMedia() {
    var parent_id = $('#published-media #parent_id').val();
    var q = $('#published-media #q').val();
    var url = $('#published-media').data('url');

    $('#published-media .items').addClass('fetching');
    $.ajax({
      url: url,
      data: {'parent_id': parent_id, 'q': q},
      dataType: 'html',
      success: function(response) {
        $("#published-media .items").html(response);
        $('#published-media .items').removeClass('fetching');
        updateViewAllLinks();
      },
      error: function(response, textStatus, xhr) {
        console.log(response);
        console.log(textStatus);
      }
    });
  }
  // make it global for usage in media_upload.js.erb
  window.loadPublishedMedia = loadPublishedMedia;


  function updateViewAllLinks() {
    var parent_id = $('#published-media #parent_id').val();
    var q = $('#published-media #q').val();
    $('#published-media .view-all').each(function(){
      var key = $(this).data('key');
      var params = {parent_id: parent_id, q: q, key: key}
      var href = $(this).attr('href');
      href = href.replace(/\?.*/, '?'+$.param(params));
      $(this).attr('href', href);
    });
  }


  $('#published-media #parent_id').change(function(){
    loadPublishedMedia()
  });


  // Using a immediate function to make timer variable only visible for the keyup event
  (function() {
    var timer = null;

    $("#published-media #q").keyup(function() {
      if(this.value.length > 2) {
        timer = setTimeout(loadPublishedMedia, 750);
      }
    }).keydown(function() {
        clearTimeout(timer);
    });
  }) ();


  $("#published-media #q").bind('notext', function(){
    loadPublishedMedia()
  });


  $("#new-folder-dialog").submit(function( event ) {
    var name = $('#new_folder').val();
    var parent_id = $("#new-folder-dialog #parent_id").val();
    $.ajax({
      url: this.action,
      type: 'POST',
      data: {
        'parent_id': parent_id,
        'article': {'name': name, 'published': true},
        'type': $('input[name=folder_type]:checked').val() },
      dataType: 'json',
      beforeSend: function(){$("#new-folder-dialog").addClass('fetching')},
      success: function(response) {
        var option_selected = "<option value='"+ response.id +"' selected='selected'>"+ response.full_name +"</options>"
        var option = "<option value='"+ response.id +"'>"+ response.full_name +"</options>"
        $('#media-upload-form #parent_id').append(option_selected);
        $('#published-media #parent_id').append(option);
        $('#new_folder').val('');
      },
      error: function(response, textStatus, xhr) {
        console.log(response);
        console.log(textStatus);
      },
      complete: function(response){
        $("#new-folder-dialog").removeClass('fetching');
        $("#new-folder-dialog").dialog('close');
      }
    });
    return false;
  });

  $('.icon-vertical-toggle').click(function(){
    $('#content').toggleClass('show-media-panel');
    return false;
  });


  $('#new-folder-button').click(function(){
    $('#new-folder-dialog').dialog({modal: true});
    return false;
  });

}) (jQuery);
