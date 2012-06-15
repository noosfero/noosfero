jQuery(function($) {
  $(".lead-button").live('click', function(){
    article_id = this.getAttribute("article_id");
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $(article_id).slideToggle();
    return false;
  })
  $("#body-button").click(function(){
    $(this).toggleClass('icon-add').toggleClass('icon-remove');
    $('#article-body-field').slideToggle();
    return false;
  })

  $("#textile-quickref-show").click(function(){
    $('#textile-quickref-hide').show();
    $(this).hide();
    $('#textile-quickref').slideToggle();
    return false;
  })
  $("#textile-quickref-hide").click(function(){
    $('#textile-quickref-show').show();
    $(this).hide();
    $('#textile-quickref').slideToggle();
    return false;
  })
  function list_items(items, selector) {
    var html_for_items = '';
    var button_add = $('.text-editor-sidebar meta[name=button.add]').attr('value');
    var button_zoom = $('.text-editor-sidebar meta[name=button.zoom]').attr('value');
    $.each(items, function(i, item) {
      if (item.error) {
        html_for_items += '<div class="media-upload-error">' + item.error + '</div>';
        return;
      }
      if (item.content_type && item.content_type.match(/^image/)) {
        html_for_items += '<div class="item" data-item="span"><span><img src="' + item.url + '"/></span><div class="controls image-controls"><a class="button with-text icon-add" data-item-url="' + item.url + '" href="#">' + button_add + '</a> <a class="button icon-zoom" href="#" title="' + button_zoom + '"><span>' + button_zoom + '/span></a></div></div>';
      } else {
        html_for_items += '<div class="item ' + item.icon + '" data-item="div"><div><a href="' + item.url + '">' + item.title + '</a></div> <div class="controls file-controls"> <a class="button with-text icon-add" data-item-url="' + item.url + '" href="#">' + button_add + '</a></div></div>';
      }
    });
    $(selector).html(html_for_items);
    $(selector).find('.controls a.icon-add').click(function() {
      var $item = $(this).closest('.item');
      var html_selector = $item.attr('data-item');
      insert_item_in_text($item.find(html_selector));
      return false;
    });
    $(selector).find('.controls a.icon-zoom').click(function() {
      alert('zoom!');
      // FIXME zoom in in the image
      return false;
    });
  }

  // FIXME the user may also want to add the item to the abstract textarea!
  var text_field = 'article_body';

  function insert_item_in_text($wrapper) {
    if (window.tinymce) {

      var html = $wrapper.html();

      var editor = tinymce.get(text_field);

      editor.setContent(editor.getContent() + html);

    } else {
      // simple text editor
      var text = $('#' + text_field).val();
      var $item = $wrapper.children().first();
      if ($item.attr('src')) {
        $('#article_body').val(text + '!' + $item.attr('src') + '!');
      }
      if ($item.attr('href')) {
        $('#article_body').val(text + $item.attr('href'));
      }
    }
  }
  $('#media-search-button').click(function() {
    var query = '*' + $('#media-search-query').val() + '*';
    var $button = $(this);
    $('#media-search-box .header').toggleClass('icon-loading');
    $.get($(this).parent().attr('action'), { 'q': query }, function(data) {
      list_items(data, '#media-search-results .items');
      if (data.length && data.length > 0) {
        $('#media-search-results').slideDown();
      }
    $('#media-search-box .header').toggleClass('icon-loading');
    });
    return false;
  });
  $('#media-upload-form form').ajaxForm({
    dataType: 'json',
    resetForm: true,
    beforeSubmit:
      function() {
        $('#media-upload-form').slideUp();
        $('#media-upload-box .header').toggleClass('icon-loading');
      },
    success:
      function(data) {
        list_items(data, '#media-upload-results .items');
        if (data.length && data.length > 0) {
          $('#media-upload-results').slideDown();
        }
        $('#media-upload-box .header').toggleClass('icon-loading');
      }
  });
  $('#media-upload-more-files').click(function() {
    $('#media-upload-results').hide();
    $('#media-upload-form').show();
  });

});
