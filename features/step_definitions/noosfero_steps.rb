Given /^the following users?$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    person_data = item.dup
    person_data.delete("login")
    User.create!(:login => item[:login], :password => '123456', :password_confirmation => '123456', :email => item[:login] + "@example.com", :person_data => person_data)
  end
end

Given /^the following (community|communities|enterprises?)$/ do |kind,table|
  klass = kind.singularize.camelize.constantize
  table.hashes.each do |row|
    owner = row.delete("owner")
    community = klass.create!(row)
    if owner
      community.add_admin(Profile[owner])
    end
  end
end

Given /^the following blocks$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    klass = item.delete('type')
    owner = Profile[item.delete('owner')]
    box_id = owner.boxes.last.id
    klass.constantize.create!(item.merge(:box_id => box_id))
  end
end

Given /^the following (articles|events|blogs|folders)$/ do |content, table|
  klass = {
    'articles' => TextileArticle,
    'events' => Event,
    'blogs' => Blog,
    'folders' => Folder,
  }[content] || raise("Don't know how to build %s" % content)
  table.hashes.map{|item| item.dup}.each do |item|
    owner_identifier = item.delete("owner")
    owner = Profile[owner_identifier]
    klass.create!(item.merge(:profile => owner))
  end
end

Given /^the following files$/ do |table|
  table.hashes.each do |item|
    owner = Profile[item[:owner]]
    file = "/files/#{item[:file]}"
    article = UploadedFile.new(:profile => owner, :uploaded_data => fixture_file_upload(file, item[:mime]))
    if item[:parent]
      article.parent = Article.find_by_slug(item[:parent])
    end
    article.save!
    if item[:homepage]
      owner.home_page = article
      owner.save!
    end
  end
end

Given /^the following products$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    owner = Enterprise[data.delete("owner")]
    category = Category.find_by_slug(data.delete("category"))
    product = Product.create!(data.merge(:enterprise => owner, :product_category => category))
    image = Image.create!(:owner => product, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
  end
end

Given /^the following states$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    if validator = Enterprise.find_by_name(data.delete("validator_name"))
      State.create!(data.merge(:environment => Environment.default, :validators => [validator]))
    else
      r = State.create!(data.merge(:environment => Environment.default))
    end
  end
end

Given /^the following validation info$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    organization = Organization.find_by_name(data.delete("organization_name"))
    ValidationInfo.create!(data.merge(:organization => organization))
  end
end

Given /^the following (product_categories|product_category|category|categories|regions?)$/ do |kind,table|
  klass = kind.singularize.camelize.constantize
  table.hashes.each do |row|
    parent = row.delete("parent")
    if parent
      parent = Category.find_by_slug(parent.to_slug)
      row.merge!({:parent_id => parent.id})
    end
    category = klass.create!({:environment_id => Environment.default.id}.merge(row))
  end
end

Given /^I am logged in as "(.+)"$/ do |username|
  visit('/account/logout')
  visit('/account/login')
  fill_in("Username", :with => username)
  fill_in("Password", :with => '123456')
  click_button("Log in")
end

Given /^I am logged in as admin$/ do
  visit('/account/logout')
  user = User.create!(:login => 'admin_user', :password => '123456', :password_confirmation => '123456', :email => 'admin_user@example.com')
  e = Environment.default
  e.add_admin(user.person)
  visit('/account/login')
  fill_in("Username", :with => user.login)
  fill_in("Password", :with => '123456')
  click_button("Log in")
end

Given /^I am not logged in$/ do
  visit('/account/logout')
end

Given /^feature "(.+)" is (enabled|disabled) on environment$/ do |feature, status|
  e = Environment.default
  status.chop!
  e.send status, feature
  e.save
end

Given /^organization_approval_method is "(.+)" on environment$/ do |approval_method|
   e = Environment.default
   e.organization_approval_method = approval_method
   e.save
end

Given /^"(.+)" is a member of "(.+)"$/ do |person,profile|
  Profile.find_by_name(profile).add_member(Profile.find_by_name(person))
end

Then /^"(.+)" should be a member of "(.+)"$/ do |person,profile|
  Profile.find_by_name(profile).members.should include(Person.find_by_name(person))
end

When /^"(.*)" is accepted on community "(.*)"$/ do |person, community|
  person = Person.find_by_name(person)
  community = Community.find_by_name(community)
  community.affiliate(person, Profile::Roles.member(community.environment.id))
end

Given /^"(.+)" is admin of "(.+)"$/ do |person, organization|
  org = Profile.find_by_name(organization)
  user = Profile.find_by_name(person)
  org.add_admin(user)
end

Given /^"([^\"]*)" has no articles$/ do |profile|
  (Profile[profile] || Profile.find_by_name(profile)).articles.delete_all
end

Given /^the following (\w+) fields are (\w+) fields$/ do |klass, status, table|
  env = Environment.default
  fields = table.raw.inject({}) do |hash, line|
    hash[line.first] = {}
    hash[line.first].merge!({ "active" => 'true' })   if status == "active"
    hash[line.first].merge!({ "required" => 'true'})  if status == "required"
    hash[line.first].merge!({ "signup" => 'true'})    if status == "signup"
    hash
  end

  env.send("custom_#{klass.downcase}_fields=", fields)
  env.save!

  if fields.keys != env.send("#{status}_#{klass.downcase}_fields")
    raise "Not all fields #{status}! Requested: %s; #{status.camelcase}: %s" % [fields.keys.inspect, env.send("#{status}_#{klass.downcase}_fields").inspect]
  end
end

Then /^"([^\"]*)" should have the following data$/ do |id, table|
  profile = Profile.find_by_identifier(id)
  expected = table.hashes.first
  data = expected.keys.inject({}) { |hash, key| hash[key] = profile.send(key).to_s; hash }
  data.should == expected
end

Given /^(.+) is member of (.+)$/ do |person, group|
  Organization[group].add_member(Person[person])
end

Given /^"(.+)" is friend of "(.+)"$/ do |person, friend|
  Person[person].add_friend(Person[friend])
end

Given /^(.+) is blocked$/ do |enterprise_name|
  enterprise = Enterprise.find_by_name(enterprise_name)
  enterprise.block
end

Given /^(.+) is disabled$/ do |enterprise_name|
  enterprise = Enterprise.find_by_name(enterprise_name)
  enterprise.enabled = false
  enterprise.save
end

Then /^The page title should contain "(.*)"$/ do |text|
  response.should have_selector("title:contains('#{text}')")
end
