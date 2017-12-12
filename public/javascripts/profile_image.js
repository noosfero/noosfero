$(function() {
    $('#picture-input').on('change', function(event) {
      var files = event.target.files;
      var image = files[0]
      var reader = new FileReader();
      reader.onload = function(file) {
        var img = new Image(98, 100);
        img.src = file.target.result;
        $('#preview-image').html(img);
        $('#preview-text').html($('#preview-text').data('label'));
      }
      reader.readAsDataURL(image);
    });
  });
