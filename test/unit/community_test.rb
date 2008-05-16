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

end
