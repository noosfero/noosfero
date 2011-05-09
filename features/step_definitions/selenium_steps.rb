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
  (selenium.is_element_present(string_to_element_locator(selector)) && selenium.is_visible(string_to_element_locator(selector))).should be_true
end
Then /^the content "([^\"]*)" should be visible$/ do |selector|
  selenium.is_visible(string_to_element_locator("content=#{selector}")).should be_true
end

Then /^the "([^\"]*)" should not be visible$/ do |selector|
  (selenium.is_element_present(string_to_element_locator(selector)) && selenium.is_visible(string_to_element_locator(selector))).should be_false
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

When /^I select window "([^\"]*)"$/ do |selector|
  selenium.select_window(selector)
end

When /^I fill in "([^\"]*)" within "([^\"]*)" with "([^\"]*)"$/ do |field_label, parent_class, value|
  selenium.type("xpath=//*[contains(@class, '#{parent_class}')]//*[@id=//label[contains(., '#{field_label}')]/@for]", value)
end

When /^I press "([^\"]*)" within "([^\"]*)"$/ do |button_value, selector|
  selenium.click("css=#{selector} input[value=#{button_value}]")
  selenium.wait_for_page_to_load(10000)
end

Then /^there should be ([1-9][0-9]*) "([^\"]*)" within "([^\"]*)"$/ do |number, child_class, parent_class|
  # Using xpath is the only way to count
  response.selenium.get_xpath_count("//*[contains(@class,'#{parent_class}')]//*[contains(@class,'#{child_class}')]").to_i.should be(number.to_i)
end

Then /^"([^\"]*)" should be (left|right) aligned$/ do |element_class, align|
  # Using xpath is the only way to count
  response.selenium.get_xpath_count("//*[contains(@class,'#{element_class}') and contains(@style,'float: #{align}')]").to_i.should be(1)
end

When /^I confirm$/ do
  selenium.get_confirmation
end

When /^I type "([^\"]*)" in TinyMCE field "([^\"]*)"$/ do |value, field_id|
  response.selenium.type("dom=document.getElementById('#{field_id}_ifr').contentDocument.body", value)
end

When /^I answer the captcha$/ do
  question = response.selenium.get_text("//label[@for='task_captcha_solution']").match(/What is the result of '(.+) = \?'/)[1]
  answer = eval(question)
  response.selenium.type("id=task_captcha_solution", answer)
end

When /^I refresh the page$/ do
  response.selenium.refresh
end

When /^I click on the logo$/ do
  selenium.click("css=h1#site-title a")
  selenium.wait_for_page_to_load(10000)
end

When /^I open (.*)$/ do |url|
  selenium.open(URI.join(response.selenium.get_location, url))
end

Then /^the page title should be "([^"]+)"$/ do |text|
  selenium.get_text("//title").should == text
end

#### Noosfero specific steps ####

Then /^the select for category "([^\"]*)" should be visible$/ do |name|
  sleep 2 # FIXME horrible hack to wait categories selection scolling to right
  category = Category.find_by_name(name)
  selenium.is_visible(string_to_element_locator("option=#{category.id}")).should be_true
end
