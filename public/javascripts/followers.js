$("#action-follow").live("click", function() {
  var button = $(this);
  var url = button.attr("href");
  loading_for_button(button);

  $.post(url, function(data) {
    button.fadeOut("fast", function() {
      $("#circles-container").html(data);
      $("#circles-container").fadeIn();
    });
  }).always(function() {
    hide_loading_for_button(button);
  });
  return false;
});

$("#cancel-set-circle").live("click", function() {
  $("#circles-container").fadeOut("fast", function() {
    $("#action-follow").fadeIn();
  });
  return false;
});

$("#new-circle").live("click", function() {
  $(this).fadeOut();
  $("#circle-actions").fadeOut("fast", function() {
    $("#new-circle-form").fadeIn();
  });
  return false;
});

$("#new-circle-cancel").live("click", function() {
  $("#new-circle-form").fadeOut("fast", function() {
    $("#circle-actions").fadeIn();
    $("#new-circle").fadeIn();
    $("#text-field-name-new-circle").val('')
  });
  return false;
});

$('#follow-circles-form').live("submit", function() {
  var valuesToSubmit = $(this).serialize();
  $.ajax({
    type: "POST",
    url: $(this).attr('action'),
    data: valuesToSubmit,
    dataType: "JSON",
    statusCode: {
      200: function(response){
        $("#circles-container").fadeOut();
        $("#action-unfollow").fadeIn();
        $.colorbox.close();
        display_notice(response.responseText);
      },
      400: function(response) {
        display_notice(response.responseText);
      }
    }
  })
    return false;
});

$("#new-circle-submit").live("click", function() {
  $.ajax({
    method: 'POST',
    url: $(this).attr("href"),
    data: {'circle[name]': $("#text-field-name-new-circle").val(),
      'circle[profile_type]': $("#circle_profile_type").val()},
    success: function(response) {
      $('#circles-checkboxes').append(response);
    },
    error: function(response) {
      display_notice(response.responseText);
    },
    complete: function(response) {
      $("#text-field-name-new-circle").val('')
      $("#new-circle-cancel").trigger("click");
    }
  })
  return false;
});
