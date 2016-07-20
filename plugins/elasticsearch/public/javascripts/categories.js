var main = function() {
  var categories = []
  var categoryParam = "";
  var url = window.location.href;
  var indexOfCategories;

  $(".categories ul li input[checked]").map(function(idx, element) {
    categories.push(element.value);
  });

  $('.categories ul li input[type=checkbox]').on('click', function(){
    var dataParams = {};

    url = url.replace(/.*\?/, "");
    var params = url.split('&');
    console.log("Dataparams: ", params);
    params.map(function(param) {
      var item = param.split('=');
      dataParams[item[0]] = item[1];
    });

    var idx = categories.indexOf(this.value);
    if (idx == -1) {
      categories.push(this.value);
    } else {
      categories.splice(idx, 1);
    }

    dataParams['categories'] = categories.join(",")

    $.ajax({
      method: "GET",
      url: "/search?format=js",
      data: dataParams
    });
  });
};

$(document).ready(main);
