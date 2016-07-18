function toggle_strategy(strategyName) {
  if (strategyName == "noosfero_oauth2") {
    $(".client-url").addClass("required-field");
  } else {
    $(".client-url").removeClass("required-field");
  }
}

$(document).on("change", "select#oauth_client_plugin_provider_strategy", function() {
  var selectedOption = $(this).find(":selected").text();
  toggle_strategy(selectedOption);
});
