When /^I choose the search filter "(.*)"$/ do |filter|
  # Wish this worked instead...
  # find("li", :text => filter).click
  page.execute_script("jQuery('li[title=#{filter}]').click();")
end
