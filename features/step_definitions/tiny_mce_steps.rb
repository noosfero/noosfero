Then /^The tinymce "(.+)" should be "(.+)"$/ do |item, content|
  item_value = page.evaluate_script("tinyMCE.activeEditor.getParam('#{item}');")
  item_value.to_s.should == content
end

Then /^The tinymce "(.+)" should contain "(.+)"$/ do |item, content|
  item_value = page.evaluate_script("tinyMCE.activeEditor.getParam('#{item}');")
  expect(item_value.to_s).to have_content(content)
end
