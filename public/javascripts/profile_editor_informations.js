(function($){
	'use strict';

	$("#profile_data_closed_false").click(function(){
		$("#requires_email_option").prop("checked",false);
		$("#requires_email_option").hide();
	});

	$("#profile_data_closed_true").click(function(){
		$("#requires_email_option").show();
	});

	$("#advanced_options_button").click(function() {
		$("#advanced_options").toggle();
	});

})(jQuery);
