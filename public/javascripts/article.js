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
  function insert_items(items, selector) {
    var html_for_items = '';
    $.each(items, function(i, item) {
      if (item.content_type && item.content_type.match(/^image/)) {
        html_for_items += '<li class="icon-photos"><img src="' + item.url + '"/><br/><a href="' + item.url + '">' + item.title + '</a></li>';
      } else {
        html_for_items += '<li class="' + item.icon + '"><a href="' + item.url + '">' + item.title + '</a></li>';
      }
    });
    $(selector).html(html_for_items);
  }
  $('#media-search-button').click(function() {
    var query = '*' + $('#media-search-query').val() + '*';
    var $button = $(this);
    $button.toggleClass('icon-loading');
    $.get($(this).parent().attr('action'), { 'q': query }, function(data) {
      insert_items(data, '#media-search-results ul');
      if (data.length && data.length > 0) {
        $('#media-search-results').slideDown();
      }
      $button.toggleClass('icon-loading');
    });
    return false;
  });
  $('#media-upload-form form').ajaxForm({
    dataType: 'json',
    resetForm: true,
    beforeSubmit:
      function() {
        $('#media-upload-form').slideUp();
        $('#media-upload-box').toggleClass('icon-loading');
      },
    success:
      function(data) {
        insert_items(data, '#media-upload-results ul');
        if (data.length && data.length > 0) {
          $('#media-upload-results').slideDown();
        }
        $('#media-upload-box').toggleClass('icon-loading');
      }
  });
  $('#media-upload-more-files').click(function() {
    $('#media-upload-results').hide();
    $('#media-upload-form').show();
  });

});
