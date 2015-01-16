When /^I choose the search filter "(.*)"$/ do |filter|
  # Wish this worked instead...
  # find("li", :text => filter).click
  page.execute_script("jQuery('li[title=#{filter}]').click();")
end

When /^I choose the following communities to spread$/ do |table|
  table.hashes.each do |row|
    name = row.delete("name")
    # We seem to have to wait for the page to load js
    sleep 1
    page.execute_script("jQuery('#token-input-search-communities-to-publish').trigger('focus').val('#{name}').trigger('keydown')")

    # We use this to wait for the search
    page.should have_selector('.token-input-dropdown li')

    page.execute_script ("jQuery('.token-input-dropdown li:contains(\"#{name}\")').trigger('mousedown');")
    page.should have_selector('li.token-input-token')
  end
end
