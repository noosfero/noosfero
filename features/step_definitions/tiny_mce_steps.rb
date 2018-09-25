Then /^The tinymce "(.+)" with index "(.+)" should be "(.+)"$/ do |item, index, content|
  item_value = page.evaluate_script("tinyMCE.get()[0].getParam('#{item}')")
  index = index.to_i
  item_value[index].to_s.should == content
end

And /^The tinymce "(.+)" should contain "(.+)"$/ do |item, content|
  item_value = page.evaluate_script("tinyMCE.get()[0].getParam('#{item}')")
  item_value.to_s.should == content
end

Given(/^I type "(.*?)" in TinyMCE field "(.*?)"$/) do |content, field|
          page.evaluate_script("tinyMCE.get('#{field}').setContent('#{content}');")
end

