require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

def string_to_element_locator(selector)
  if selector.gsub!(/^\./, '')
    "css=[class='#{selector}']"
  elsif selector.gsub!(/^value[.=]/, '')
    "xpath=//input[@value='#{selector}']"
  elsif selector.gsub!(/^option=/, '')
    "xpath=//option[@value='#{selector}']"
  elsif selector.gsub!(/^#/, '')
    "css=[id='#{selector}']"
  elsif selector.gsub!(/^content=/, '')
    "xpath=//*[.='#{selector}']"
  elsif selector.gsub!(/^li=/, '')
    "xpath=//li[contains(.,'#{selector}')]"
  else
    selector
  end
end

Then /^the "([^\"]*)" should be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator(selector)).should be_true
end
Then /^the content "([^\"]*)" should be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator("content=#{selector}")).should be_true
end

Then /^the "([^\"]*)" should not be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator(selector)).should be_false
end
Then /^the content "([^\"]*)" should not be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator("content=#{selector}")).should be_false
end

When /^I click "([^\"]*)"$/ do |selector|
  selenium.click(string_to_element_locator(selector))
end

Then /^the "([^\"]*)" button should not be enabled$/ do |text|
  selenium.is_editable(string_to_element_locator(text)).should be_false
end

Then /^the "([^\"]*)" button should be enabled$/ do |text|
  selenium.is_editable(string_to_element_locator("value.#{text}")).should be_true
end

Then /^I should see "([^\"]*)" above of "([^\"]*)"$/ do |above, below|
  above_position = selenium.get_element_position_top(string_to_element_locator("li=#{above}"))
  below_position = selenium.get_element_position_top(string_to_element_locator("li=#{below}"))
  above_position.to_i.should < below_position.to_i
end

When /^I drag "([^\"]*)" to "([^\"]*)"$/ do |from, to|
  selenium.drag_and_drop_to_object(string_to_element_locator("li=#{from}"), string_to_element_locator("li=#{to}"))
  selenium.wait_for_ajax
end

When /^I select "([^\"]*)" and wait for (jquery)$/ do |value, framework|
  select(value)
  # FIXME ugly hack to make selenium tests waiting to render page
  # "select(value, :wait_for => :ajax)" did not effect
  selenium.wait_for(:wait_for => :ajax, :javascript_framework => framework)
end

#### Noosfero specific steps ####

Then /^the select for category "([^\"]*)" should be visible$/ do |name|
  sleep 2 # FIXME horrible hack to wait categories selection scolling to right
  category = Category.find_by_name(name)
  selenium.is_visible(string_to_element_locator("option=#{category.id}")).should be_true
end
