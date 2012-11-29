Then /^"([^"]*)" should not be visible within "([^"]*)"$/ do |text, selector|
  if page.has_content?(text)
    page.should have_no_css(selector, :text => text, :visible => false)
  end
end
