Given /^the user "(.+)" has the following circles$/ do |user_name,table|
  person = User.find_by(:login => user_name).person
  table.hashes.each do |circle|
    Circle.create!(:person => person, :name => circle[:name], :profile_type => circle[:profile_type])
  end
end

Then /^"(.+)" should be a follower of "(.+)" in circle "(.+)"$/ do |person, profile, circle|
  profile =  Profile.find_by(identifier: profile)
  followers = profile.followers
  person = Person.find_by(identifier: person)
  followers.should include(person)

  circle = Circle.find_by(:name => circle, :person => person)
  ProfileFollower.find_by(:circle => circle, :profile => profile).should_not == nil
end

Then /^"(.+)" should not be a follower of "(.+)"$/ do |person, profile|
  profile =  Profile.find_by(identifier: profile)
  followers = profile.followers
  person = Person.find_by(identifier: person)
  followers.should_not include(person)
end

Given /^"(.+)" is a follower of "(.+)" in circle "(.+)"$/ do |person, profile, circle|
  profile =  Profile.find_by(identifier: profile)
  person = Person.find_by(identifier: person)
  circle = Circle.find_by(:name => circle, :person => person)
  ProfileFollower.create!(:circle => circle, :profile => profile)
end

Then /^"(.+)" should have the circle "(.+)" with profile type "(.+)"$/ do |user_name, circle, profile_type|
  person = User.find_by(:login => user_name).person
  Circle.find_by(:name => circle, :person => person, :profile_type => profile_type).should_not == nil
end
