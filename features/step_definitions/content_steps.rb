When /^I create a content of type "([^\"]*)" with the following data$/ do |content_type, fields|
  click_link "New content"
  click_link content_type

  fields.rows_hash.each do |name, value|
    step %{I fill in "#{name}" with "#{value}"}
  end

  click_button "Save"
end

And /^I add to "([^\"]*)" the following exception "([^\"]*)"$/ do |article_name, user_exception|
  article = Article.find_by_name(article_name)
  community = article.profile
  raise "The article profile is not a community." unless community.class == Community

  my_user = community.members.find_by_name(user_exception)
  raise "Could not find #{user_exception} in #{community.name} community." if my_user.nil?

  article.article_privacy_exceptions << my_user
  article.save
end
