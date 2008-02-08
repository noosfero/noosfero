require File.dirname(__FILE__) + '/../test_helper'

class CommunityTest < Test::Unit::TestCase

  should 'inherit from Profile' do
    assert_kind_of Profile, Community.new
  end

  should 'convert name into identifier' do
    c = Community.new(:name =>'My shiny new Community')
    assert_equal 'My shiny new Community', c.name
    assert_equal 'my-shiny-new-community', c.identifier
  end

  should 'have a description attribute' do
    c = Community.new
    c.description = 'the description of the community'
    assert_equal 'the description of the community', c.description
  end

  should 'allow to add new members' do
    c = Community.create!(:name => 'my test community')
    p = create_user('mytestuser').person

    c.add_member(p)

    assert c.members.include?(p), "Community should add the new member"
  end

end
