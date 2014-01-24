Given /^"([^\"]*)" is a sub organization of "([^\"]*)"$/ do |child, parent|
  child = Organization.find_by_name(child) || Organization[child]
  parent = Organization.find_by_name(parent) || Organization[parent]

  SubOrganizationsPlugin::Relation.add_children(parent, child)
end
