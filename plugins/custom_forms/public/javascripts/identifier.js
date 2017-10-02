camelize = function camelize(str) {
      return str.replace(/[A-Z]?\s?/g, function(match, chr)
       {
            temp_replace = match.toLowerCase();
	    return temp_replace.replace(/\s/g, '-')
        });
    }

function buildIdentifierValue() {
  $("#form_name").blur(function () {
	  form_name = $("#form_name").val();

	  $("#form_identifier").val(camelize(form_name));
  });
};

$(window).on("load", buildIdentifierValue());
