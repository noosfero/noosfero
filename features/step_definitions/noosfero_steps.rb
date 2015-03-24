Given /^the following users?$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    person_data = item.dup
    person_data.delete("login")
    category = Category.find_by_slug person_data.delete("category")
    email = item[:email] || item[:login] + "@example.com"
    user = User.create!(:login => item[:login], :password => '123456', :password_confirmation => '123456', :email => email, :person_data => person_data)
    user.activate
    p = user.person
    p.categories << category if category
    p.save!
    user.save!
  end
end

Given /^"(.+)" is (invisible|visible)$/ do |user, visibility|
  User.find_by_login(user).person.update_attributes({:visible => (visibility == 'visible')}, :without_protection => true)
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
    category = row.delete("category")
    img_name = row.delete("img")
    city = row.delete("region")
    organization = klass.create!(row, :without_protection => true)
    if owner
      organization.add_admin(Profile[owner])
    end
    if domain
      d = Domain.new :name => domain, :owner => organization
      d.save(:validate => false)
    end
    if city
      c = City.find_by_name city
      organization.region = c
    end
    if category && !category.blank?
      cat = Category.find_by_slug category
      ProfileCategorization.add_category_to_profile(cat, organization)
    end
    if img_name
      img = Image.create!(:uploaded_data => fixture_file_upload('/files/'+img_name+'.png', 'image/png'))
      organization.image = img
    end
    organization.save!
  end
end

Given /^"([^\"]*)" is associated with "([^\"]*)"$/ do |enterprise, bsc|
  enterprise = Enterprise.find_by_name(enterprise) || Enterprise[enterprise]
  bsc = BscPlugin::Bsc.find_by_name(bsc) || BscPlugin::Bsc[bsc]

  bsc.enterprises << enterprise
end

Then /^"([^\"]*)" should be associated with "([^\"]*)"$/ do |enterprise, bsc|
  enterprise = Enterprise.find_by_name(enterprise) || Enterprise[enterprise]
  bsc = BscPlugin::Bsc.find_by_name(bsc) || BscPlugin::Bsc[bsc]

  bsc.enterprises.should include(enterprise)
end

Given /^the folllowing "([^\"]*)" from "([^\"]*)"$/ do |kind, plugin, table|
  klass = (plugin.camelize+'::'+kind.singularize.camelize).constantize
  table.hashes.each do |row|
    owner = row.delete("owner")
    domain = row.delete("domain")
    organization = klass.create!(row)
    if owner
      organization.add_admin(Profile[owner])
    end
    if domain
      d = Domain.new :name => domain, :owner => organization
      d.save(:validate => false)
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

Given /^the following (articles|events|blogs|folders|forums|galleries|uploaded files|rss feeds)$/ do |content, table|
  klass = {
    'articles' => TextileArticle,
    'events' => Event,
    'blogs' => Blog,
    'folders' => Folder,
    'forums' => Forum,
    'galleries' => Gallery,
    'uploaded files' => UploadedFile,
    'rss feeds' => RssFeed,
  }[content] || raise("Don't know how to build %s" % content)
  table.hashes.map{|item| item.dup}.each do |item|
    owner_identifier = item.delete("owner")
    parent = item.delete("parent")
    owner = Profile[owner_identifier]
    home = item.delete("homepage")
    language = item.delete("language")
    category = item.delete("category")
    filename = item.delete("filename")
    translation_of_id = nil
    if item["translation_of"]
      if item["translation_of"] != "nil"
        article = owner.articles.find_by_name(item["translation_of"])
        translation_of_id = article.id if article
      end
      item.delete("translation_of")
    end
    item.merge!(
      :profile => owner,
      :language => language,
      :translation_of_id => translation_of_id)
    if !filename.blank?
      item.merge!(:uploaded_data => fixture_file_upload("/files/#{filename}", 'binary/octet-stream'))
    end
    result = klass.new(item)
    if !parent.blank?
      result.parent = Article.find_by_name(parent)
    end
    if category
      cat = Category.find_by_slug category
      if cat
        result.add_category(cat)
      end
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
    data.merge!(:enterprise => owner, :product_category => category)
    if data[:img]
      img = Image.create!(:uploaded_data => fixture_file_upload('/files/'+data.delete("img")+'.png', 'image/png'))
      data.merge!(:image_id => img.id)
    end
    if data[:qualifier]
      qualifier = Qualifier.find_by_name(data.delete("qualifier"))
      data.merge!(:qualifiers => [qualifier])
    end
    product = Product.create!(data, :without_protection => true)
  end
end

Given /^the following inputs?$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    product = Product.find_by_name(data.delete("product"))
    category = Category.find_by_slug(data.delete("category").to_slug)
    unit = Unit.find_by_singular(data.delete("unit"))
    solidary = data.delete("solidary")
    input = Input.create!(data.merge(:product => product, :product_category => category, :unit => unit,
                                     :is_from_solidarity_economy => solidary), :without_protection => true)
    input.update_attribute(:position,  data['position'])
  end
end

Given /^the following states$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    if validator = Enterprise.find_by_name(data.delete("validator_name"))
      State.create!(data.merge(:environment => Environment.default, :validators => [validator]), :without_protection => true)
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
    if !parent.blank?
      parent = Category.find_by_slug(parent.to_slug)
      row.merge!({:parent_id => parent.id})
    end
    category = klass.create!({:environment => Environment.default}.merge(row))
  end
end

Given /^the following qualifiers$/ do |table|
  table.hashes.each do |row|
    Qualifier.create!(row.merge(:environment_id => 1), :without_protection => true)
  end
end

Given /^the following certifiers$/ do |table|
  table.hashes.each do |row|
    row = row.dup
    qualifiers_list = row.delete("qualifiers")
    if qualifiers_list
      row["qualifiers"] = qualifiers_list.split(', ').map{|i| Qualifier.find_by_name(i)}
    end
    Certifier.create!(row.merge(:environment_id => 1), :without_protection => true)
  end
end

Given /^the following production costs?$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    owner_type = item.delete('owner')
    owner = owner_type == 'environment' ? Environment.default : Profile[owner_type]
    ProductionCost.create!(item.merge(:owner => owner))
  end
end

Given /^the following price details?$/ do |table|
  table.hashes.map{|item| item.dup}.each do |item|
    product = Product.find_by_name item.delete('product')
    production_cost = ProductionCost.find_by_name item.delete('production_cost')
    product.price_details.create!(item.merge(:production_cost => production_cost))
  end
end

Given /^I am logged in as "(.+)"$/ do |username|
  Given %{I go to logout page}
  And %{I go to login page}
  And %{I fill in "main_user_login" with "#{username}"}
  And %{I fill in "user_password" with "123456"}
  When %{I press "Log in"}
  And %{I go to #{username}'s control panel}
  Then %{I should be on #{username}'s control panel}
  @current_user = username
end

Given /^"([^"]*)" is environment admin$/ do |person|
  user = Profile.find_by_name(person)
  e = Environment.default

  e.add_admin(user)
end

Given /^I am logged in as admin$/ do
  visit('/account/logout')
  user = User.create!(:login => 'admin_user', :password => '123456', :password_confirmation => '123456', :email => 'admin_user@example.com')
  user.activate
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
  e.send status.chop, feature
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

Given /^"(.+)" is moderator of "(.+)"$/ do |person, organization|
  org = Profile.find_by_name(organization)
  user = Profile.find_by_name(person)
  org.add_moderator(user)
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

Given /^enterprise "([^\"]*)" is blocked$/ do |enterprise_name|
  enterprise = Enterprise.find_by_name(enterprise_name)
  enterprise.block
end

Given /^enterprise "([^\"]*)" is disabled$/ do |enterprise_name|
  enterprise = Enterprise.find_by_name(enterprise_name)
  enterprise.enabled = false
  enterprise.save
end

Then /^the page title should be "(.*)"$/ do |text|
  page.title.should == text
end

Then /^The page should contain "(.*)"$/ do |selector|
  page.should have_css("#{selector}")
end

Then /^The page should not contain "(.*)"$/ do |selector|
  page.should have_no_css("#{selector}")
end

Given /^the mailbox is empty$/ do
  ActionMailer::Base.deliveries = []
end

Given /^the (.+) mail (?:is|has) (.+) (.+)$/ do |position, field, value|
  if(/^[0-9]+$/ =~ position)
    ActionMailer::Base.deliveries[position.to_i][field].to_s == value
  else
    ActionMailer::Base.deliveries.send(position)[field].to_s == value
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

Then /^I should be logged in as "(.+)"$/ do |username|
   When %{I go to #{username}'s control panel}
   Then %{I should be on #{username}'s control panel}
end

Then /^I should not be logged in as "(.+)"$/ do |username|
   When %{I go to #{username}'s control panel}
   Then %{I should be on login page}
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
  table.hashes.map{|item| item.dup}.each do |item|
    target = Community[item.delete('target')]
    task = SuggestArticle.create!(:target => target, :data => item)
  end
end

Given /^the following units?$/ do |table|
  table.hashes.each do |row|
    Unit.create!(row.merge(:environment_id => 1), :without_protection => true)
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
  d.save(:validate => false)
end

When /^([^\']*)'s account is activated$/ do |person|
  Person.find_by_name(person).user.activate
end

Then /^I should receive an e-mail on (.*)$/ do |address|
  last_mail = ActionMailer::Base.deliveries.last
  last_mail.nil?.should be_false
  last_mail['to'].to_s.should == address
end

Given /^"([^\"]*)" plugin is (enabled|disabled)$/ do |plugin_name, status|
  environment = Environment.default
  environment.send(status.chop + '_plugin', plugin_name+'Plugin')
end

Then /^there should be an? (.+) named "([^\"]*)"$/ do |klass_name, profile_name|
  klass = klass_name.camelize.constantize
  klass.find_by_name(profile_name).nil?.should be_false
end

Then /^"([^\"]*)" profile should exist$/ do |profile_selector|
  profile = nil
  begin
    profile = Profile.find_by_name(profile_selector)
    profile.nil?.should be_false
  rescue
    profile.nil?.should be_false
  end
end

Then /^"([^\"]*)" profile should not exist$/ do |profile_selector|
  profile = nil
  begin
    profile = Profile.find_by_name(profile_selector)
    profile.nil?.should be_true
  rescue
    profile.nil?.should be_true
  end
end

When 'I log off' do
  visit '/account/logout'
end

Then /^I should be taken to "([^\"]*)" product page$/ do |product_name|
  product = Product.find_by_name(product_name)
  path = url_for(product.enterprise.public_profile_url.merge(:controller => 'manage_products', :action => 'show', :id => product, :only_path => true))
  if response.class.to_s == 'Webrat::SeleniumResponse'
    URI.parse(response.selenium.get_location).path.should == path_to(path)
  else
    URI.parse(current_url).path.should == path_to(path)
  end
end

Given /^the following enterprise homepages?$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    data = item.dup
    home = EnterpriseHomepage.new(:name => data[:name])
    ent = Enterprise.find_by_identifier(data[:enterprise])
    ent.articles << home
  end
end

And /^I want to add "([^\"]*)" as cost$/ do |string|
  prompt = page.driver.browser.switch_to.alert
  prompt.send_keys(string)
  prompt.accept
end

Given /^([^\s]+) (enabled|disabled) translation redirection in (?:his|her) profile$/ do
  |login, status|
  profile = Profile[login]
  profile.redirect_l10n = ( status == "enabled" )
  profile.save
end

Given /^the following cities$/ do |table|
  table.hashes.each do |item|
    state = State.find_by_acronym item[:state]
    if !state
      state = State.create!(:name => item[:state], :acronym => item[:state], :environment_id => Environment.default.id)
    end
    city = City.create!(:name => item[:name], :environment_id => Environment.default.id)
    city.parent = state
    city.save!
  end
end

When /^I edit my profile$/ do
  visit "/myprofile/#{@current_user}"
  click_link "Edit Profile"
end

Given /^the following tags$/ do |table|
  table.hashes.each do |item|
    article = Article.find_by_name item[:article]
    article.tag_list.add item[:name]
    article.save!
  end
end

When /^I search ([^\"]*) for "([^\"]*)"$/ do |asset, query|
  When %{I go to the search #{asset} page}
  And %{I fill in "search-input" with "#{query}"}
  And %{I press "Search"}
end

Then /^I should see ([^\"]*)'s product image$/ do |product_name|
  p = Product.find_by_name product_name
  path = url_for(p.enterprise.public_profile_url.merge(:controller => 'manage_products', :action => 'show', :id => p))

  with_scope('.zoomable-image') do
    page.should have_xpath("a[@href=\"#{path}\"][@class='search-image-pic']")
  end
end

Then /^I should not see ([^\"]*)'s product image$/ do |product_name|
  p = Product.find_by_name product_name
  path = url_for(p.enterprise.public_profile_url.merge(:controller => 'manage_products', :action => 'show', :id => p))

  with_scope('.zoomable-image') do
    page.should have_no_xpath("a[@href=\"#{path}\"][@class='search-image-pic']")
  end
end

Then /^I should see ([^\"]*)'s profile image$/ do |name|
  page.should have_xpath("//img[@alt=\"#{name}\"]")
end

Then /^I should not see ([^\"]*)'s profile image$/ do |name|
  page.should have_no_xpath("//img[@alt=\"#{name}\"]")
end

Then /^I should see ([^\"]*)'s community image$/ do |name|
  page.should have_xpath("//img[@alt=\"#{name}\"]")
end

Then /^I should not see ([^\"]*)'s community image$/ do |name|
  page.should have_no_xpath("//img[@alt=\"#{name}\"]")
end

Given /^the article "([^\"]*)" is updated by "([^\"]*)"$/ do |article, person|
  a = Article.find_by_name article
  p = Person.find_by_name person
  a.last_changed_by = p
  a.save!
end

Given /^the article "([^\"]*)" is updated with$/ do |article, table|
  a = Article.find_by_name article
  row = table.hashes.first
  a.update_attributes(row)
end

Given /^the cache is turned (on|off)$/ do |state|
  ActionController::Base.perform_caching = (state == 'on')
end

Given /^the environment is configured to (.*) after login$/ do |option|
  redirection = case option
    when 'stay on the same page'
      'keep_on_same_page'
    when 'redirect to site homepage'
      'site_homepage'
    when 'redirect to user profile page'
      'user_profile_page'
    when 'redirect to profile homepage'
      'user_homepage'
    when 'redirect to profile control panel'
      'user_control_panel'
  end
  environment = Environment.default
  environment.redirection_after_login = redirection
  environment.save
end

Given /^the profile (.*) is configured to (.*) after login$/ do |profile, option|
  redirection = case option
    when 'stay on the same page'
      'keep_on_same_page'
    when 'redirect to site homepage'
      'site_homepage'
    when 'redirect to user profile page'
      'user_profile_page'
    when 'redirect to profile homepage'
      'user_homepage'
    when 'redirect to profile control panel'
      'user_control_panel'
  end
  profile = Profile.find_by_identifier(profile)
  profile.redirection_after_login = redirection
  profile.save
end

Given /^the environment is configured to (.*) after signup$/ do |option|
  redirection = case option
    when 'stay on the same page'
      'keep_on_same_page'
    when 'redirect to site homepage'
      'site_homepage'
    when 'redirect to user profile page'
      'user_profile_page'
    when 'redirect to profile homepage'
      'user_homepage'
    when 'redirect to profile control panel'
      'user_control_panel'
    when 'redirect to welcome page'
      'welcome_page'
  end
  environment = Environment.default
  environment.redirection_after_signup = redirection
  environment.save
end

When /^wait for the captcha signup time$/ do
  environment = Environment.default
  sleep environment.min_signup_delay + 1
end

Given /^there are no pending jobs$/ do
  silence_stream(STDOUT) do
    Delayed::Worker.new.work_off
  end
end

When /^I confirm the "(.*)" dialog$/ do |confirmation|
  a = page.driver.browser.switch_to.alert
  assert_equal confirmation, a.text
  a.accept
end

Given /^the field (.*) is public for all users$/ do |field|
  Person.all.each do |person|
    person.fields_privacy = Hash.new if person.fields_privacy.nil?
    person.fields_privacy[field] = "public"
    person.save!
  end
end
