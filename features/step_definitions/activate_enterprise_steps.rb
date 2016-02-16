Given /^I fill in "([^\"]*)" with code of "([^\"]*)"$/ do |field, enterprise|
  enterprise = Enterprise.find_by_name(enterprise)
  value = EnterpriseActivation.all.select { |task| task.enterprise == enterprise}.first.code
  fill_in(field, :with => value)
end

Given /^enterprise "([^\"]*)" should be enabled$/ do |enterprise|
  Enterprise.find_by_name(enterprise).enabled?.should be_truthy
end

Given /^"([^\"]*)" is the active enterprise template$/ do |enterprise|
  template = Enterprise.find_by_name(enterprise)
  template.boxes.destroy_all
  template.boxes << Box.new
  template.layout_template = 'leftbar'
  template.theme = 'template_theme'
  template.custom_header = 'template header'
  template.custom_footer = 'template_footer'
  template.save!

  e = Environment.default
  e.enterprise_default_template = template
  e.save
end

Given /^"([^\"]*)" has "([^\"]*)" as template$/ do |ent, templ|
  template = Enterprise.find_by_name(templ)
  enterprise = Enterprise.find_by_name(ent)
  (template.boxes.size == enterprise.boxes.size).should be_truthy
  (template.layout_template == enterprise.layout_template).should be_truthy
  (template.theme == enterprise.theme).should be_truthy
  (template.custom_header == enterprise.custom_header).should be_truthy
  (template.custom_footer == enterprise.custom_footer).should be_truthy
end

Given /^"([^\"]*)" doesnt have "([^\"]*)" as template$/ do |ent, templ|
  template = Enterprise.find_by_name(templ)
  enterprise = Enterprise.find_by_name(ent)
  (template.boxes.size == enterprise.boxes.size).should be_falsey
  (template.layout_template == enterprise.layout_template).should be_falsey
  (template.theme == enterprise.theme).should be_falsey
  (template.custom_header == enterprise.custom_header).should be_falsey
  (template.custom_footer == enterprise.custom_footer).should be_falsey
end

Given /^enterprise "([^\"]*)" is enabled$/ do |enterprise|
  Enterprise.find_by_name(enterprise).update_attribute(:enabled,true)
  Enterprise.find_by_name(enterprise).enabled?.should be_truthy
end

Given /^enterprise "([^\"]*)" should be blocked$/ do |enterprise|
  Enterprise.find_by_name(enterprise).blocked?.should be_truthy
end

Given /^enterprise "([^\"]*)" should not be blocked$/ do |enterprise|
  Enterprise.find_by_name(enterprise).blocked?.should_not be_truthy
end

Given /^enterprise template must be replaced after enable$/ do
  e = Environment.default
  e.replace_enterprise_template_when_enable = true
  e.save
end

Given /^enterprise template must not be replaced after enable$/ do
  e = Environment.default
  e.replace_enterprise_template_when_enable = false
  e.save
end
