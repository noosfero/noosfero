jQuery(function($) {
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

  var button_add = $('.text-editor-sidebar span.button-add').attr('data-value');
  var button_zoom = $('.text-editor-sidebar span.button-zoom').attr('data-value');
  var button_close = $('.text-editor-sidebar span.button-close').attr('data-value');

  function add_to_text_button(extra_class) {
    if (!extra_class) { extra_class = '' }
    return '<a class="button icon-add add-to-text ' + extra_class + '" href="#"><span>' + button_add + '</span></a>';
  }

  function close_button(extra_class) {
    if (!extra_class) { extra_class = '' }
    return '<a class="button icon-cancel close ' + extra_class + '" href="#"><span>' + button_close + '</span></a>';
  }

  function zoom_button() {
    return '<a class="button icon-zoom zoom" href="#" title="' + button_zoom + '"><span>' + button_zoom + '</span></a>';
  }

  function list_items(items, selector, auto_add) {
    var html_for_items = '';

    var images  = [];
    var files   = [];
    var errors  = [];

    $.each(items, function(i, item) {
      if (item.error) {
        errors.push(item);
        return;
      }
      if (item.content_type && item.content_type.match(/^image/)) {
        images.push(item);
      } else {
        files.push(item);
      }
    });

    $.each(images, function(i, item) {
      html_for_items += '<div class="item image" data-item="span"><span><img src="' + item.url + '"/></span><div class="controls image-controls">' + add_to_text_button() + zoom_button() + '</div></div>';
    });

    $.each(files, function(i, item) {
      html_for_items += '<div class="item file ' + item.icon + '" data-item="div"><div><a href="' + item.url + '">' + item.title + '</a></div> <div class="controls file-controls">' + add_to_text_button() + '</div></div>';
    });

    $.each(errors, function(i, item) {
      html_for_items += '<div class="media-upload-error">' + item.error + '</div>';
    });

    $(selector).html(html_for_items);

    if (auto_add) {
      $(selector).find('a.add-to-text').click();
    }
  }

  function zoom_dialog_html(name, img) {
    // FIXME organize this code better
    return '<h3 style="text-align: center;">'+ name +'</h3><div class="item" data-item="div"><div><img src="' + img + '" style="max-width: 640px; max-height: 480px"/></div>' + '<div class="button-bar">' + add_to_text_button('with-text') + '&nbsp;&nbsp;&nbsp;' + close_button('with-text') + '</div></div>'
  }

  $('.view-all-images .item').live('click', function(){
    insert_item_in_text(jQuery(this).find('span'));
    $.colorbox.close();
  });

  $('a.add-to-text').live('click', function() {
    var $item = $(this).closest('.item');
    var html_selector = $item.attr('data-item');
    insert_item_in_text($item.find(html_selector));
    noosfero.modal.close();
    return false;
  });
  $('a.zoom').live('click', function() {
    var $item = $(this).closest('.item');
    var html_selector = $item.attr('data-item');
    var name = $item.attr('title');
    var img = $item.find(html_selector).find('img').attr('src');
    noosfero.modal.html(zoom_dialog_html(img), {
      scrolling: false,
    });
    return false;
  });
  $('a.close').live('click', function() {
    noosfero.modal.close();
    return false;
  })

  // FIXME the user may also want to add the item to the abstract textarea!
  var text_field = 'article_body';

  function insert_item_in_text($wrapper) {
    if (window.tinymce) {

      var html = $wrapper.html();

      var editor = tinymce.get(text_field);

      editor.setContent(editor.getContent() + html);

    } else {
      // simple text editor
      var $text_element = $('#' + text_field);
      var text = $text_element.val();
      var $item = $wrapper.children().first();
      if ($item.attr('src')) {
        $text_element.val(text + '!' + $item.attr('src') + "!\n");
      }
      if ($item.attr('href')) {
        $text_element.val(text + $item.attr('href'));
      }
    }
  }

  $('#media-search-button').click(function() {
    var query = $('#media-search-query').val();
    var $button = $(this);
    $('#media-search-box .header').toggleClass('icon-loading');
    $.get($(this).parent().attr('action'), { 'q': query }, function(data) {
      list_items(data, '#media-search-results .items', false);
      if (data.length && data.length > 0) {
        $('#media-search-results').slideDown();
      }
      $('#media-search-box .header').toggleClass('icon-loading');
    });
    return false;
  });

  $('#media-upload-form form').ajaxForm({
    resetForm: true,
    beforeSubmit:
    function() {
      $('#media-upload-form').slideUp();
      $('#media-upload-box .header').toggleClass('icon-loading');
    },
    success:
    function(text) {
      text = text.replace('<pre>', '').replace('</pre>', ''); // old firefox
      var data = $.parseJSON(text);
      list_items(data, '#media-upload-results .items', true);
      if (data.length && data.length > 0) {
        $('#media-upload-results').slideDown();
      }
      $('#media-upload-box .header').toggleClass('icon-loading');
    }
  });

  $('#media-upload-more-files').click(function() {
    $('#media-upload-results').hide();
    $('#media-upload-form').show();
    return false;
  });

  function is_public_article() {
    return $("#article_published_true").attr('checked');
  }

  function show_hide_privacy_options() {
    var show_privacy_options = $("#article_published_false").attr('checked');
    var custom_privacy_option = $(".custom_privacy_option").parent("div");

    if( show_privacy_options ) {
      custom_privacy_option.show();
    } else {
      custom_privacy_option.hide();
    }
    show_hide_token_input();
  }

  function show_hide_token_input() {
    var display_token =  $(".custom_privacy_option:checked").length == 0;
    var token_field = $("#text-input-search-exception-users").parent("div");

    if( display_token && !is_public_article() ) {
      token_field.css('display', 'block');
    } else {
      token_field.css('display', 'none');
    }
  }

  if( $("#token-input-search-article-privacy-exceptions").length == 1 ) {
    show_hide_privacy_options();
    show_hide_token_input();
  }

  $(document).ready(function(){
    show_hide_privacy_options();
  });

  //Hide / Show the text area
  $("#article_published_false").click(show_hide_privacy_options);
  $("#article_published_true").click(show_hide_privacy_options);
  $(".custom_privacy_option").click(show_hide_token_input);

});
