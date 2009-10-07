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

Given /^the following (articles|events)$/ do |content, table|
  klass = {
    'articles' => TextileArticle,
    'events' => Event,
  }[content] || raise("Don't know how to build %s" % content)
  table.hashes.each do |item|
    data = item.dup
    owner_identifier = data.delete("owner")
    owner = Profile[owner_identifier]
    TextileArticle.create!(data.merge(:profile => owner))
  end
end

Given /^the following products$/ do |table|
  table.hashes.each do |item|
    data = item.dup
    owner = Enterprise[data.delete("owner")]
    Product.create!(data.merge(:enterprise => owner))
  end
end

