Then /^The tinymce "(.+)" should be "(.+)"$/ do |item, content|
  item_value = page.evaluate_script("tinyMCE.activeEditor.getParam('#{item}');")
  assert_equal item_value.to_s, content
end

Then /^The tinymce "(.+)" should contain "(.+)"$/ do |item, content|
  item_value = page.evaluate_script("tinyMCE.activeEditor.getParam('#{item}');")
  assert_include item_value.to_s, content
end
