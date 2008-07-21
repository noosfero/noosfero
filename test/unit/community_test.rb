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

  should 'create default set of blocks' do
    c = Community.create!(:name => 'my new community')

    assert c.boxes[0].blocks.map(&:class).include?(MainBlock)

    assert c.boxes[1].blocks.map(&:class).include?(ProfileInfoBlock)
    assert c.boxes[1].blocks.map(&:class).include?(RecentDocumentsBlock)

    assert c.boxes[2].blocks.map(&:class).include?(MembersBlock)
    assert c.boxes[2].blocks.map(&:class).include?(TagsBlock)

    assert_equal 5,  c.blocks.size
  end

  should 'get a default home page and RSS feed' do
    community = Community.create!(:name => 'my new community')

    assert_kind_of Article, community.home_page
    assert_kind_of RssFeed, community.articles.find_by_path('feed')
  end

  should 'have contact_person' do
    community = Community.new(:name => 'my new community')
    assert_respond_to community, :contact_person
  end

  should 'allow to add new members' do
    c = Community.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    c.add_member(p)

    assert c.members.include?(p), "Community should add the new member"
  end

  should 'allow to remove members' do
    c = Community.create!(:name => 'my other test profile', :identifier => 'myothertestprofile')
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'clear relationships after destroy' do
    c = Community.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    member = create_user('memberuser').person
    admin = create_user('adminuser').person
    moderator = create_user('moderatoruser').person

    c.add_member(member)
    c.add_admin(admin)
    c.add_moderator(moderator)

    relationships = c.role_assignments
    assert_not_nil relationships

    c.destroy
    relationships.each do |i|
      assert !RoleAssignment.exists?(i.id)
    end
  end

end
