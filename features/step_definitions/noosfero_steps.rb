def selenium_driver?
  self.class.to_s == 'Webrat::SeleniumSession'
end

Given /^the following users?$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    person_data = item.dup
    person_data.delete("login")
    User.create!(:login => item[:login], :password => '123456', :password_confirmation => '123456', :email => item[:login] + "@example.com", :person_data => person_data)
  end
end

Given /^"(.+)" is (online|offline|busy) in chat$/ do |user, status|
  status = {'online' => 'chat', 'offline' => '', 'busy' => 'dnd'}[status]
  User.find_by_login(user).update_attributes(:chat_status => status, :chat_status_at => DateTime.now)
end

Given /^the following (community|communities|enterprises?|organizations?)$/ do |kind,table|
  klass = kind.singularize.camelize.constantize
  table.hashes.each do |row|
    owner = row.delete("owner")
    domain = row.delete("domain")
    organization = klass.create!(row)
    if owner
      organization.add_admin(Profile[owner])
    end
    if domain
      d = Domain.new :name => domain, :owner => organization
      d.save(false)
    end
  end
end

Given /^the following blocks$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    klass = item.delete('type')
    owner_type = item.delete('owner')
    owner = owner_type == 'environment' ? Environment.default : Profile[owner_type]
    if owner.boxes.empty?
      owner.boxes<< Box.new
      owner.boxes.first.blocks << MainBlock.new
    end
    box_id = owner.boxes.last.id
    klass.constantize.create!(item.merge(:box_id => box_id))
  end
end

Given /^the following (articles|events|blogs|folders|forums|galleries)$/ do |content, table|
  klass = {
    'articles' => TextileArticle,
    'events' => Event,
    'blogs' => Blog,
    'folders' => Folder,
    'forums' => Forum,
    'galleries' => Gallery
  }[content] || raise("Don't know how to build %s" % content)
  table.hashes.map{|item| item.dup}.each do |item|
    owner_identifier = item.delete("owner")
    parent = item.delete("parent")
    owner = Profile[owner_identifier]
    home = item.delete("homepage")
    result = klass.new(item.merge(:profile => owner))
    if parent
      result.parent = Article.find_by_name(parent)
    end
    result.save!
    if home == 'true'
      owner.home_page = result
      owner.save!
    end
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

Given /^the following articles? with images?$/ do |table|
  table.hashes.each do |item|
    owner = Profile[item[:owner]]
    file = item[:image]
    img = { :src => "/images/#{file}", :alt => file }
    img[:width] = item[:dimensions].split('x')[0] if item[:dimensions]
    img[:height] = item[:dimensions].split('x')[1] if item[:dimensions]
    img[:style] = item[:style] if item[:style]
    img_tag = "<img "
    img.each { |attr, value| img_tag += "#{attr}=\"#{value}\" " }
    img_tag += "/>"
    article = TinyMceArticle.new(:profile => owner, :name => item[:name], :body => img_tag)
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

Given /^the following products?$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    owner = Enterprise[data.delete("owner")]
    category = Category.find_by_slug(data.delete("category").to_slug)
    img = Image.create!(:uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    product = Product.create!(data.merge(:enterprise => owner, :product_category => category, :image_id => img.id))
  end
end

Given /^the following inputs?$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    product = Product.find_by_name(data.delete("product"))
    category = Category.find_by_slug(data.delete("category").to_slug)
    unit = Unit.find_by_singular(data.delete("unit"))
    input = Input.create!(data.merge(:product => product, :product_category => category, :unit => unit))
    input.update_attributes!(:position => data['position'])
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

Given /^the following qualifiers$/ do |table|
  table.hashes.each do |row|
    Qualifier.create!(row.merge(:environment_id => 1))
  end
end

Given /^the following certifiers$/ do |table|
  table.hashes.each do |row|
    row = row.dup
    qualifiers_list = row.delete("qualifiers")
    if qualifiers_list
      row["qualifiers"] = qualifiers_list.split(', ').map{|i| Qualifier.find_by_name(i)}
    end
    Certifier.create!(row.merge(:environment_id => 1))
  end
end

Given /^I am logged in as "(.+)"$/ do |username|
  visit('/account/logout')
  visit('/account/login')
  fill_in("Username", :with => username)
  fill_in("Password", :with => '123456')
  click_button("Log in")
  # FIXME selenium do not wait page load sometimes
  if selenium_driver?
    selenium.wait_for_page
  end
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
  # FIXME selenium do not wait page load sometimes
  if selenium_driver?
    selenium.wait_for_page
  end
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

Then /^"(.+)" should be admin of "(.+)"$/ do |person, organization|
  org = Organization.find_by_name(organization)
  user = Person.find_by_name(person)
  org.admins.should include(user)
end

Then /^"(.+)" should be moderator of "(.+)"$/ do |person,profile|
  profile = Profile.find_by_name(profile)
  person = Person.find_by_name(person)
  profile.members_by_role(Profile::Roles.moderator(profile.environment.id)).should include(person)
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
  if response.class.to_s == 'Webrat::SeleniumResponse'
    response.selenium.text('css=title').should include(text)
  else
    response.should have_selector("title:contains('#{text}')")
  end
end

Given /^the mailbox is empty$/ do
  ActionMailer::Base.deliveries = []
end

Given /^the (.+) mail (?:is|has) (.+) (.+)$/ do |position, field, value|
  if(/^[0-9]+$/ =~ position)
    ActionMailer::Base.deliveries[position.to_i][field] == value
  else
    ActionMailer::Base.deliveries.send(position)[field] == value
  end
end

Given /^the (.+) mail (.+) is like (.+)$/ do |position, field, regexp|
  re = Regexp.new(regexp)
  if(/^[0-9]+$/ =~ position)
    re =~ ActionMailer::Base.deliveries[position.to_i][field.to_sym]
  else
    re =~ ActionMailer::Base.deliveries.send(position)[field.to_sym]
  end
end

Given /^the following environment configuration$/ do |table|
  env = Environment.default
  table.raw.each do |item|
    env.send("#{item[0]}=", item[1])
  end
  env.save
end

Then /^I should be logged in as "(.+)"$/ do |login|
  User.find(session[:user]).login.should == login
end

Given /^the profile "(.+)" has no blocks$/ do |profile|
  profile = Profile[profile]
  profile.boxes.map do |box|
    box.blocks.destroy_all
  end
end

Given /^the articles of "(.+)" are moderated$/ do |organization|
  organization = Organization.find_by_name(organization)
  organization.moderated_articles = true
  organization.save
end

Given /^the following comments?$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    article = Article.find_by_name(data.delete("article"))
    author = data.delete("author")
    comment = article.comments.build(data)
    if author
      comment.author = Profile[author]
    end
    comment.save!
  end
end

Given /^the community "(.+)" is closed$/ do |community|
  community = Community.find_by_name(community)
  community.closed = true
  community.save
end

Given /^someone suggested the following article to be published$/ do |table|
  SuggestArticle.skip_captcha!
  table.hashes.map{|item| item.dup}.each do |item|
    target = Community[item.delete('target')]
    task = SuggestArticle.create!(:target => target, :data => item)
  end
end

Given /^the following units?$/ do |table|
  table.hashes.each do |row|
    Unit.create!(row.merge(:environment_id => 1))
  end
end

Given /^"([^\"]*)" asked to join "([^\"]*)"$/ do |person, organization|
  person = Person.find_by_name(person)
  organization = Organization.find_by_name(organization)
  AddMember.create!(:person => person, :organization => organization)
end

Given /^that the default environment have (.+) templates?$/ do |option|
  env = Environment.default
  case option
    when 'all profile'
      env.create_templates
    when 'no Inactive Enterprise'
      env.inactive_enterprise_template && env.inactive_enterprise_template.destroy
  end
end

Given /^the environment domain is "([^\"]*)"$/ do |domain|
  d = Domain.new :name => domain, :owner => Environment.default
  d.save(false)
end
