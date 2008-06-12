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

  should 'be found in search for its product categories' do
    ent1 = Enterprise.create!(:name => 'test1', :identifier => 'test1')
    prod_cat = ProductCategory.create!(:name => 'pctest', :environment => Environment.default)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_cat)

    ent2 = Enterprise.create!(:name => 'test2', :identifier => 'test2')

    result = Enterprise.find_by_contents(prod_cat.name)

    assert_includes result, ent1
    assert_not_includes result, ent2
  end

   should 'be found in search for its product categories hierarchy' do
    ent1 = Enterprise.create!(:name => 'test1', :identifier => 'test1')
    prod_cat = ProductCategory.create!(:name => 'pctest', :environment => Environment.default)
    prod_child = ProductCategory.create!(:name => 'pchild', :environment => Environment.default, :parent => prod_cat)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_child)

    ent2 = Enterprise.create!(:name => 'test2', :identifier => 'test2')

    result = Enterprise.find_by_contents(prod_cat.name)

    assert_includes result, ent1
    assert_not_includes result, ent2
  end

  should 'not allow to add new members' do
    o = Enterprise.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    o.add_member(p)
    o.reload

    assert_not_includes  o.members, p
  end

  should 'allow to remove members' do
    c = Enterprise.create!(:name => 'my other test profile', :identifier => 'myothertestprofile')
    c.expects(:closed?).returns(false)
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'return coherent code' do
    ent = Enterprise.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    ent2 = Enterprise.create!(:name => 'my test profile 2', :identifier => 'mytestprofile2')

    assert_equal ent, Enterprise.return_by_code(ent.code)
    assert_nil Enterprise.return_by_code(ent.code.next)
  end

  should 'have foudation_year' do
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent')

    assert_respond_to ent, 'foundation_year'
    assert_respond_to ent, 'foundation_year='
  end

  should 'have cnpj' do
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent')

    assert_respond_to ent, 'cnpj'
    assert_respond_to ent, 'cnpj='
  end

end
