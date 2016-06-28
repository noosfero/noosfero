$(document).ready(function(){
	select_box_event();
});

var toggle_info_message = function(){
  var selected_option = $("#oauth_client_plugin_provider_strategy option:selected");
  if (selected_option.length){
    if (selected_option.val() === "twitter"){
      $(".remember-enable-email").removeClass("hidden");
    } else {
      $(".remember-enable-email").addClass("hidden");
    }
  }
};

var select_box_event = function(){
	var select_box = $("#oauth_client_plugin_provider_strategy");
	select_box.on("change",function(){
		toggle_info_message();
	});
};
