require_relative "../test_helper"

class CircleTest < ActiveSupport::TestCase

  should 'two circles with same name and different profile types' do
    person = create_user('testinguser').person

    circle1 = create(Circle, :name => 'test', :profile_type => 'Enterprise', :person => person)
    circle2 = create(Circle, :name => 'test', :profile_type => 'Community', :person => person)

    circles = Circle.all
    assert_includes circles, circle2
  end

  should 'two circles with same name and same profile types' do
    person = create_user('testinguser').person
  
    circle1 = create(Circle, :name => 'test', :profile_type => 'Enterprise', :person => person)
    circle2 = Circle.new(:name => 'test', :profile_type => 'Enterprise', :person => person)
    refute circle2.valid?
  end
  
  should 'two circles with different names and same profile types' do
    person = create_user('testinguser').person
  
    circle1 = create(Circle, :name => 'test', :profile_type => 'Enterprise', :person => person)
    circle2 = create(Circle, :name => 'different-test', :profile_type => 'Enterprise', :person => person)
  
    circles = Circle.all
    assert_includes circles, circle2
  end
  
  should 'two circles with different names and different profile types' do
    person = create_user('testinguser').person
  
    circle1 = create(Circle, :name => 'test', :profile_type => 'Enterprise', :person => person)
    circle2 = create(Circle, :name => 'different-test', :profile_type => 'Community', :person => person)

    circles = Circle.all
    assert_includes circles, circle2
  end
  
end
