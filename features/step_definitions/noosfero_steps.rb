Given /^the following users$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    person_data = item.dup
    person_data.delete("login")
    User.create!(:login => item[:login], :password => '123456', :password_confirmation => '123456', :email => item[:login] + "@example.com", :person_data => person_data)
  end
end

Given /^the following communities$/ do |table|
  table.hashes.each do |item|
    Community.create!(item)
  end
end

Given /^the following enterprises$/ do |table|
  table.hashes.each do |item|
    Enterprise.create!(item)
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

Given /^the following (articles|events|blogs)$/ do |content, table|
  klass = {
    'articles' => TextileArticle,
    'events' => Event,
    'blogs' => Blog,
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
    article = UploadedFile.create!(:profile => owner, :uploaded_data => fixture_file_upload(file, item[:mime]))
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
    Product.create!(data.merge(:enterprise => owner))
  end
end

Given /^I am logged in as "(.+)"$/ do |username|
  fill_in("Username", :with => username)
  fill_in("Password", :with => '123456')
  click_button("Log in")
end
