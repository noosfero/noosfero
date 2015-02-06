Then /^I should (not )?see an element "([^"]*)"$/ do |negate, selector|
  expectation = negate ? :should_not : :should
  page.html.send(expectation, have_css(selector))
end

Then /^"([^"]*)" should be selected for "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    field_labeled(field).find(:xpath, ".//option[@selected = 'selected'][text() = '#{value}']").should be_present
  end
end

Then /^(?:|I )should see div with title "([^"]*)"(?: within "([^"]*)")?$/ do |name, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_xpath(".//div[@title='#{name}']")
    else
      assert page.has_xpath?(".//div[@title='#{name}']")
    end
  end
end

Then /^(?:|I )should not see div with title "([^"]*)"(?: within "([^"]*)")?$/ do |name, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_xpath(".//div[@title='#{name}']")
    else
      assert page.has_no_xpath?(".//div[@title='#{name}']")
    end
  end
end
