require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTest < Test::Unit::TestCase
  fixtures :profiles, :environments, :users

  def test_identifier_validation
    p = Enterprise.new
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'with space'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'áéíóú'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'rightformat2007'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'rightformat'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'right_format'
    p.valid?
    assert ! p.errors.invalid?(:identifier)
  end

  def test_has_domains
    p = Enterprise.new
    assert_kind_of Array, p.domains
  end

  def test_belongs_to_environment_and_has_default
    assert_equal Environment.default, Enterprise.create!(:name => 'my test environment', :identifier => 'mytestenvironment').environment
  end

  def test_cannot_rename
    p1 = profiles(:johndoe)
    assert_raise ArgumentError do
      p1.identifier = 'bli'
    end
  end

  should 'remove products when removing enterprise' do
    e = Enterprise.create!(:name => "My enterprise", :identifier => 'myenterprise')
    e.products.build(:name => 'One product').save!
    e.products.build(:name => 'Another product').save!

    assert_difference Product, :count, -2 do
      e.destroy
    end
  end

  should 'get a default homepage and RSS feed' do
    enterprise = Enterprise.create!(:name => 'my test enterprise', :identifier => 'myenterprise')

    assert_kind_of Article, enterprise.home_page
    assert_kind_of RssFeed, enterprise.articles.find_by_path('feed')
  end

  should 'create default set of blocks' do
    e = Enterprise.create!(:name => 'my new community', :identifier => 'mynewcommunity')

    assert e.boxes[0].blocks.map(&:class).include?(MainBlock), 'enterprise must have a MainBlock upon creation'

    assert e.boxes[1].blocks.map(&:class).include?(ProfileInfoBlock), 'enterprise must have a ProfileInfoBlock upon creation'
    assert e.boxes[1].blocks.map(&:class).include?(RecentDocumentsBlock), 'enterprise must have a RecentDocumentsBlock upon creation'

    assert e.boxes[2].blocks.map(&:class).include?(MembersBlock), 'enterprise must have a MembersBlock upon creation'
    assert e.boxes[2].blocks.map(&:class).include?(TagsBlock), 'enterprise must have a TagsBlock upon creation'

    assert_equal 5,  e.blocks.size
  end

  should 'allow to add new members' do
    o = Enterprise.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    o.add_member(p)

    assert o.members.include?(p), "Enterprise should add the new member"
  end
  
  should 'allow to remove members' do
    c = Enterprise.create!(:name => 'my other test profile', :identifier => 'myothertestprofile')
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

end
