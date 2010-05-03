require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

def string_to_element_locator(selector)
  if selector.gsub!(/^\./, '')
    "css=[class='#{selector}']"
  else
    raise "I can't find '#{selector}'!"
  end
end

Then /^the "([^\"]*)" should be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator(selector)).should be_true
end

Then /^the "([^\"]*)" should not be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator(selector)).should be_false
end

When /^I click "([^\"]*)"$/ do |selector|
  selenium.click(string_to_element_locator(selector))
end
