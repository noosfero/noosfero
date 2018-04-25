var jcrop_api;

function cropImage(element) {

  $("#crop-image-button").click()

  if( jcrop_api != null ) jcrop_api.destroy()

  var root = $(element.closest('.file-fieldset'))
  var preview = root.find('.preview-image')
  var input = root.find('input.picture-input')
  var width = parseInt(preview.data('width'))
  var height = parseInt(preview.data('height'))
  var select_width = width * 4
  var select_height = height * 4

  if(select_width == 0 || select_height == 0) {
    select_width = 3000
    select_height = 3000
  }

  var files = element.files
  var image = files[0]
  var reader = new FileReader()

  reader.onload = function(file) {

    var img = new Image(this.width, this.height)
    img.src = file.target.result
    preview.html(img)
    preview.show()

    $("#noosfero-modal-content #cropbox").attr("src", img.src)
    $('#noosfero-modal-content #cropbox').Jcrop({
      boxWidth: 700,
      boxHeight: 400,
      onChange: updateCrop,
      onSelect: updateCrop,
      setSelect: [0, 0, select_width, select_height],
      aspectRatio: width/height
    }, function() {
      jcrop_api = this
    })

  }
  reader.readAsDataURL(image);

  function updateCrop(coords) {

    root.find("input.crop_x").val(Math.round(coords.x))
    root.find("input.crop_y").val(Math.round(coords.y))
    root.find("input.crop_w").val(Math.round(coords.w))
    root.find("input.crop_h").val(Math.round(coords.h))

    updatePreview(coords)
  }


  function updatePreview(coords) {

    if(coords.w > coords.h) {
      aspect_ratio = coords.h / coords.w
      preview.width(100)
      preview.height(100 * aspect_ratio)
    } else {
      aspect_ratio = coords.w / coords.h
      preview.height(100)
      preview.width(100 * aspect_ratio)
    }

    proportion_x = preview.width() / coords.w
    proportion_y = preview.height() / coords.h

    preview.find('img').css({
      width: Math.round(proportion_x * $('#noosfero-modal-content #cropbox').width()) + 'px',
      height: Math.round(proportion_y * $('#noosfero-modal-content #cropbox').height()) + 'px',
      marginLeft: '-' + Math.round(proportion_x * coords.x) + 'px',
      marginTop: '-' + Math.round(proportion_y * coords.y) + 'px'
    });
  }

  $('#confirm-crop-image').live('click', function() {
    $('#close-modal').click()
    return false
  })
}

function isImage(file) {
  var mimeType= file['type']

  if(mimeType.split('/')[0]=='image'){
    return true
  } else {
    return false;
  }
}

function checkImageToCrop(element) {
  if( isImage(element.files[0]) ) {
    cropImage(element)
  }
}

function display_change_image() {
  $('#actual-image').hide('slow')
  $('#change-image').show('slow');
  $('#cancel-change-image-link').show();
  $('#change-image-link').hide('slow');
  return false;
}

function hideen_change_image() {
  $('#actual-image').show('slow')
  $('#change-image-link').show('slow')
  $('#change-image').hide('slow')
  $('#change-image input.picture-input').val('')
  $('.preview-image').hide()
  return false
}

$( document ).ready(function() {
  $('#add-cropped-image').click(function() {
   $('#crop_file').click()
   return false
  })
})

