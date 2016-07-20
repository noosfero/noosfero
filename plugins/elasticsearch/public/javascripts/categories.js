var main = function() {
  $(document).on('click', '.jstree-anchor',function(e,data){
    var url = window.location.href;
    var dataParams = {};
    var categories = $("#jstree-categories").jstree("get_checked",null,true);
    var params;

    dataParams['selected_type'] = $('#selected_type').val();
    dataParams['filter'] = $('#filter').val();
    dataParams['query'] = $('#query').val();
    dataParams['page'] = 1;
    dataParams['categories'] = categories.join(",");

    $.ajax({
      method: "GET",
      url: "/search?format=js",
      data: dataParams
    });
  });
};

$(document).ready(main);
