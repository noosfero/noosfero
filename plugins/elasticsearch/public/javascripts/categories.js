var main = function() {
  var categories = []
  var categoryParam = "";
  var url = window.location.href;
  var indexOfCategories;

  url = url.replace(/&categories.*/g, "");
  url += "&categories=";

  $(".categories ul li input[checked]").map(function(idx, element) {
    categories.push(element.value);
  });

  $('.categories ul li input[type=checkbox]').on('click', function(){
    var idx = categories.indexOf(this.value);
    if (idx == -1) {
      categories.push(this.value);
    } else {
      categories.splice(idx, 1);
    }

    url += categories.join(",");
    window.location.href = url;
  });
};

$(document).ready(main);
