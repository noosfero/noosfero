function highlight_table_row(evt) {
  var row_number = parseInt(jQuery("#highlights-data-table tr").last().attr("data-row-number"));
  var row_data = jQuery(".highlight-table-row tbody tr").clone();

  row_data.attr("data-row-number", row_number+1 || 0);
  jQuery("#highlights-data-table").append(row_data);
  jQuery(".delete-highlight").on("confirm:complete", delete_highlight);

  return false;
}

function delete_highlight(evt, answer) {
  if(answer) {
    var row_number = parseInt(jQuery(this).parent().parent().attr("data-row-number"));

    if(row_number != NaN) {
      jQuery("#highlights-data-table tr[data-row-number="+row_number+"]").remove();
    }
  }

  return false;
}

jQuery(document).ready(function(){
  jQuery(".new-highlight-button").click(highlight_table_row);
  jQuery(".delete-highlight").on("confirm:complete", delete_highlight);
});
