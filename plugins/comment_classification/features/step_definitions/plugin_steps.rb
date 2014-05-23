Given /^CommentClassificationPlugin is enabled$/ do
  step %{I am logged in as admin}
  step %{I am on the environment control panel}
  step %{I follow "Plugins"}
  step %{I check "Comment Classification"}
  step %{I press "Save changes"}
  Environment.default.enabled_plugins.should include("CommentClassificationPlugin")
end

Given /^the following labels$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    owner_type = item.delete('owner')
    owner = owner_type == 'environment' ? Environment.default : Profile[owner_type]
    CommentClassificationPlugin::Label.create!(item)
  end
end

Given /^the following status$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    owner_type = item.delete('owner')
    owner = owner_type == 'environment' ? Environment.default : Profile[owner_type]
    CommentClassificationPlugin::Status.create!(item)
  end
end
