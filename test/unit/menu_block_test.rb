require_relative "../test_helper"

class MenuBlockTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @box = create(Box, owner: profile)
    @block = MenuBlock.new(box: box)
    @person = fast_create(Person)
  end
  attr_reader :profile, :box, :block, :person

  should 'default describe' do
    assert_not_equal Block.description, MenuBlock.description
  end

  should 'is editable' do
    assert block.editable?
  end

  should 'return only about link for person when not logged in' do
    block.box = create(Box, owner: fast_create(Person))
    links = block.enabled_links_for(nil)
    assert_equal 1, links.size
    assert_equal 'About', links.first[:title]
  end

  should 'return activities link for community when user has no permission' do
    links = block.enabled_links_for(person)
    assert links.detect{|link| link[:title] == 'Activities' }
  end

  should 'return activities link for community for visitors' do
    links = block.enabled_links_for(nil)
    assert links.detect{|link| link[:title] == 'Activities' }
  end

  should 'not return activities link for person visitors' do
    person = fast_create(Person)
    box = create(Box, owner: person)
    block = MenuBlock.new(box: box)
    links = block.enabled_links_for(nil)
    assert !links.detect{|link| link[:title] == 'Activities' }
  end

  should 'return all community links for an owner' do
    profile.add_admin(person)
    links = block.enabled_links_for(person)
    assert_equal ['Activities', 'People', 'Control Panel'], links.map { |l| l[:title] }
  end

  should 'return all person links for the current person' do
    block.box = create(Box, owner: person)
    links = block.enabled_links_for(person)
    assert_equal ['Activities', 'About', 'Communities', 'People', 'Control Panel'], links.map { |l| l[:title] }
  end
end
