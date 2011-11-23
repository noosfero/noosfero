var dates = jQuery( "#from, #to" ).datepicker({
  defaultDate: "+1w",
  changeMonth: true,
  dateFormat: 'yy-mm-dd',
  onSelect: function( selectedDate ) {
    var option = this.id == "from" ? "minDate" : "maxDate",
    instance = jQuery( this ).data( "datepicker" ),
    date = jQuery.datepicker.parseDate(
       instance.settings.dateFormat ||
       jQuery.datepicker._defaults.dateFormat,
       selectedDate, instance.settings );
    dates.not( this ).datepicker( "option", option, date );
  }
});
