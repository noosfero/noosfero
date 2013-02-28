When /^I create a Mezuro (project|reading group) with the following data$/ do |type, fields|
  click_link ("Mezuro " + type)

  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end

  click_button "Save"
  Article.find_by_name(fields.rows_hash[:Title])
end

When /^I create a Mezuro configuration with the following data$/ do |fields|
  click_link ("Mezuro configuration")

  fields.rows_hash.each do |name, value|
    if name != "Clone"
      When %{I fill in "#{name}" with "#{value}"}
    end
  end

  click_button "Save"
  Article.find_by_name(fields.rows_hash[:Title])
end

Then /^I directly delete content with name "([^\"]*)" for testing purposes$/ do |content_name|
  Article.find_by_name(content_name).destroy
end

Then /^I should be at the url "([^\"]*)"$/ do |url|
  if response.class.to_s == 'Webrat::SeleniumResponse'
    URI.parse(response.selenium.get_location).path.should == url
  else
    URI.parse(current_url).path.should == url
  end
end

Then /^the field "([^"]*)" is empty$/ do |field_name|
  find_field(field_name).value.should be_nil
end

Then /^I should see "([^\"]*)" inside an alert$/ do |message|
	alert = page.driver.browser.switch_to.alert
  assert_equal message, alert.text
  alert.accept
end

Then /^I should see "([^"]*)" in the "([^"]*)" input$/ do |content, labeltext|
    find_field(labeltext).value.should == content
end

Then /^I should see "([^"]*)" button$/ do |button_name|
  find_button(button_name).should_not be_nil
end

Then /^I should see "([^"]*)" in a link$/ do |link_name|
  find_link(link_name).should_not be_nil
end

Then /^I should see "([^"]*)" in the "([^"]*)" select$/ do |content, labeltext|
    find_field(labeltext).value.strip.should == content #strip because have empty spaces around some options
end

Then /^I should see "([^"]*)" in the process period select field$/ do |content|
  selected = MezuroPlugin::Helpers::ContentViewerHelper.periodicity_options.select { |option| option.first == content }.first
  assert_equal selected.last, find_field("repository_process_period").value.to_i
end

Then /^I should see "([^"]*)" in the repository configuration select field$/ do |content|
  selected = Kalibro::Configuration.all.select { |option| option.name == content }.first
  assert_equal selected.id, find_field("repository_configuration_id").value.to_i
end

Then /^I should not see "([^"]*)" button$/ do |button_name|
  find_button(button_name).should be_nil
end

When /^I have a Mezuro (project|reading group|configuration|repository) with the following data$/ do |type,fields|
  item = {}
  fields.rows_hash.each do |name, value|
    if(name=="user" or name=="community")
      item.merge!(:profile=>Profile[value])
    else
      item.merge!(name => value)
    end
  end
  if (type == "project")
    result = MezuroPlugin::ProjectContent.new(item)
  elsif (type == "reading group")
    result = MezuroPlugin::ReadingGroupContent.new(item)
  elsif (type == "configuration")
    result = MezuroPlugin::ConfigurationContent.new(item)
  end

  if (type == "repository")
    puts Kalibro::Configuration.all.last.id
    puts Kalibro::Project.all.last.id
    item.merge(:configuration_id => Kalibro::Configuration.all.last.id)
    result = Kalibro::Repository.new(item)
    result.save Kalibro::Project.all.last.id
  else
    result.save!
   end
end

When /^I erase the "([^"]*)" field$/ do |field_name|
  find_field(field_name).set ""
end

When /^I fill the fields with the new following data$/ do |fields|
  fields.rows_hash.each do |key, value|
    name = key.to_s
    element = find_field(name)
    if element.tag_name.to_s == "select"
      select(value, :from => name)
    else
      element.set value
    end
  end
end

When /^I have a Mezuro metric configuration with previous created configuration and reading group$/ do
  Kalibro::MetricConfiguration.create({
         :code => 'amloc1',
         :metric => {:name => 'Total Coupling Factor', :compound => "false", :scope => 'SOFTWARE', :language => ['JAVA']},
         :base_tool_name => "Analizo",
         :weight => "1.0",
         :aggregation_form => 'AVERAGE',
         :reading_group_id => Kalibro::ReadingGroup.all.last.id,
         :configuration_id => Kalibro::Configuration.all.last.id
  })
end

When /^I follow the (edit|remove) link for "([^"]*)" repository$/ do |action,repository_name|
  project_id = Kalibro::Project.all.last.id
  repositories = Kalibro::Repository.repositories_of project_id
  repository_id = repositories.select {|option| option.name == repository_name}.first.id
  elements = all('a', :text => action.capitalize)
  action_link = elements.select {|element| (/repository_id=#{repository_id}/ =~ element[:href])  }.first
  action_link.click
end
