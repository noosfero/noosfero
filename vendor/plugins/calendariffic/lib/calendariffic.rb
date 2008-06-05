module Calendariffic
  
=begin rdoc
  ===Creates a DHTML pop-up calendar icon and an associated text-box to display the selected date.
  
  <b>_calendar_is_before_text_</b>: boolean to determine whether the calendar icon is placed before or after the text-box
    e.g. true will produce <img ... /><input type="text" ... /> whereas false will generate <input type="text" ... /><img ... />
    
  <b>_text_name_</b>: specifies the name and id attributes of the text-box.  The user MUST specify this value and it MUST be different from the value specified in image_name.
  
  <b>_image_source_</b>: relative path specifying the location of an icon to represent the pop-up calendar.
    Several calendar icons are located in public/images/calendariffic
    
  <b>_image_name_</b>:  the name and id you want associated with your calendar icon.  The user MUST specify this value and it MUST be different from the value specified in text_name.
  
  <b>_date_format_</b>:  the format in which the date will appear within the text_box.  See table below for valid abbreviations for date.
    a date_format of nil will default to mm/dd/yy.
  
  <b>_text_value_</b>:  the initial value you want to show up within the text box (e.g. '07/04/2007')
    if the user passes the string 'today' the text_value will initially display today's date in whichever format is specified by the date_format parameter.
    the 'today' string is case-insensitive.
  
  <b>_text_attributes_</b>: any other attributes that can be placed into an <input type="text" /> HTML element can be placed here within a Hash.  e.g. {:class => 'myfavoriteclass'}
  
  <b>_image_attributes_</b>: any other attributes that can be placed into an <img src="" ... /> HTML element can be placed here within a Hash. e.g. {:alt => 'cal'}
    

  <b>Date Formatting Abbreviations:</b>
    %a 	abbreviated weekday name  
    %A 	full weekday name    
    %b 	abbreviated month name    
    %B 	full month name  
    %C 	century number  
    %d 	the day of the month ( 00 .. 31 )  
    %e 	the day of the month ( 0 .. 31 )  
    %j 	day of the year ( 000 .. 366 )  
    %m 	month ( 01 .. 12 )  
    %n 	a newline character  
    %s 	number of seconds since Epoch (since Jan 01 1970 00:00:00 UTC)  
    %t 	a tab character  
    %U, %W, %V 	the week number  
    %u 	the day of the week ( 1 .. 7, 1 = MON )  
    %w 	the day of the week ( 0 .. 6, 0 = SUN )  
    %y 	year without the century ( 00 .. 99 )  
    %Y 	year including the century ( ex. 1979 )  
    %% 	a literal % character
=end
def calendariffic_input(calendar_is_before_text, text_name, image_source, image_name, date_format, text_value, text_attributes={}, image_attributes={})    
    image_attributes[:name] = image_name if image_name
    image_attributes[:id] = image_name if image_name
    date_format ||= '%m/%d/%y'
    
    text_value = Date.today.strftime(date_format) if text_value.to_s.upcase.eql? 'TODAY'    
    imt = image_tag(image_source, image_attributes)
    tft = text_field_tag(text_name, text_value, text_attributes)
    script = "<script language='javascript'>set_cal('#{text_name}', '#{image_name}', '#{date_format}', '#{text_value}');</script>"
    calendar_is_before_text ? "#{imt}#{tft}#{script}" : "#{tft}#{imt}#{script}"    
  end
end