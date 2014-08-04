function highlight_table_row(evt) {
  evt.preventDefault();
  jQuery("#highlights-data-table").append(jQuery(".highlight-table-row tbody").html());
}

jQuery(document).ready(function(){
  jQuery(".new-highlight-button").click(highlight_table_row);
});
