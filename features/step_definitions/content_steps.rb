When /^I create a content of type "([^\"]*)" with the following data$/ do |content_type, fields|
  click_link "New content"
  click_link content_type

  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end

  click_button "Save"
end
