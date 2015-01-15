When /^I choose the search filter "(.*)"$/ do |filter|
  # Wish this worked instead...
  # find("li", :text => filter).click
  page.execute_script("jQuery('li[title=#{filter}]').click();")
end

When /^I choose the following communities to spread$/ do |table|
  ids = []
  table.hashes.each do |row|
    name = row.delete("name")
    community = Community.find_by_name(name)
    ids << community.id
  end
  #TODO make this work somehow...
  #fill_in('q', :with => ids.join(','))
  #fill_in('#search-communities-to-publish', :with => ids.join(','))
  page.execute_script("jQuery('#search-communities-to-publish').val(#{ids.join(',')})")
  page.execute_script("jQuery('#search-communities-to-publish').show()")
  p find('#search-communities-to-publish').value
end
