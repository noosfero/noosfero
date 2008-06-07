require File.dirname(__FILE__) + '/../test_helper'

class EnvironmentTest < Test::Unit::TestCase
  fixtures :environments

  def test_exists_default_and_it_is_unique
    Environment.delete_all
    vc = Environment.new(:name => 'Test Community')
    vc.is_default = true
    assert vc.save

    vc2 = Environment.new(:name => 'Another Test Community')
    vc2.is_default = true
    assert !vc2.valid?
    assert vc2.errors.invalid?(:is_default)

    assert_equal vc, Environment.default
  end

  def test_acts_as_configurable
    vc = Environment.new(:name => 'Testing Environment')
    assert_kind_of Hash, vc.settings
    vc.settings[:some_setting] = 1
    assert vc.save
    assert_equal 1, vc.settings[:some_setting]
  end

  def test_available_features
    assert_kind_of Hash, Environment.available_features
  end

  def test_mock
    assert_equal ['feature1', 'feature2', 'feature3'], Environment.available_features.keys.sort
  end

  def test_features
    v = Environment.new
    v.enable('feature1')
    assert v.enabled?('feature1')
    v.disable('feature1')
    assert !v.enabled?('feature1')
  end

  def test_enabled_features
    v = Environment.new
    v.enabled_features = [ 'feature1', 'feature2' ]
    assert v.enabled?('feature1') && v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_enabled_features_no_features_enabled
    v = Environment.new
    v.enabled_features = nil
    assert !v.enabled?('feature1') && !v.enabled?('feature2') && !v.enabled?('feature3')
  end

  def test_name_is_mandatory
    v = Environment.new
    v.valid?
    assert v.errors.invalid?(:name)
    v.name = 'blablabla'
    v.valid?
    assert !v.errors.invalid?(:name)
  end

  def test_terms_of_use
    v = Environment.new(:name => 'My test environment')
    assert_nil v.terms_of_use
    v.terms_of_use = 'To be part of this environment, you must accept the following terms: ...'
    assert v.save
    id = v.id
    assert_equal 'To be part of this environment, you must accept the following terms: ...', Environment.find(id).terms_of_use
  end

  def test_has_terms_of_use
    v = Environment.new
    assert !v.has_terms_of_use?
    v.terms_of_use = 'some terms of use'
    assert v.has_terms_of_use?
  end

  def test_should_list_top_level_categories
    env = Environment.create!(:name => 'a test environment')
    cat1 = Category.create!(:name => 'first category', :environment_id => env.id)
    cat2 = Category.create!(:name => 'second category', :environment_id => env.id)
    subcat = Category.create!(:name => 'child category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.top_level_categories
    assert_equal 2, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert !cats.include?(subcat)
  end

  def test_should_list_all_categories
    env = Environment.create!(:name => 'a test environment')
    cat1 = Category.create!(:name => 'first category', :environment_id => env.id)
    cat2 = Category.create!(:name => 'second category', :environment_id => env.id)
    subcat = Category.create!(:name => 'child category', :environment_id => env.id, :parent_id => cat2.id)

    cats = env.categories
    assert_equal 3, cats.size
    assert cats.include?(cat1)
    assert cats.include?(cat2)
    assert cats.include?(subcat)
  end

  should 'list displayable categories' do
    env = Environment.create!(:name => 'a test environment')
    cat1 = env.categories.create(:name => 'category one', :display_color => 1)
    assert ! cat1.new_record?

    # subcategories should be ignored
    subcat1 = env.categories.create(:name => 'subcategory one', :parent_id => cat1.id)
    assert ! subcat1.new_record?

    cat2 = env.categories.create(:name => 'category two')
    assert !cat2.new_record?

    assert_equal 1,  env.display_categories.size
    assert env.display_categories.include?(cat1)
    assert !env.display_categories.include?(cat2)
  end

  should 'have regions' do
    env = Environment.create!(:name => 'a test environment')
    assert_kind_of Array, env.regions
    assert_raise ActiveRecord::AssociationTypeMismatch do
      env.regions << 1
    end
    assert_nothing_raised do
      env.regions << Region.new
    end
  end

  should 'have a contact email' do
    env = Environment.new
    assert_nil env.contact_email

    env.contact_email = 'test'
    env.valid?
    assert env.errors.invalid?(:contact_email)

    env.contact_email = 'test@example.com'
    env.valid?
    assert !env.errors.invalid?(:contact_email)
  end

  should 'provide a default hostname' do
    env = Environment.create!(:name => 'test environment')
    env.domains << Domain.create(:name => 'example.com')
    assert_equal 'example.com', env.default_hostname
  end

  should 'default to localhost as hostname' do
    env = Environment.create!(:name => 'test environment')
    assert_equal 'localhost', env.default_hostname
  end

  should 'provide an approval_method setting' do
    env = Environment.new

    # default value
    assert_equal :admin, env.organization_approval_method

    # valid values
    assert_nothing_raised do
      valid = %w[
        admin
        region
      ].each do |item|
        env.organization_approval_method = item
        env.organization_approval_method = item.to_sym
      end
    end

    # do not allow other values
    assert_raise ArgumentError do
      env.organization_approval_method = :lalala
    end
    
  end

  should 'provide environment name in to_s' do
    env = Environment.new(:name => 'my name')
    assert_equal 'my name', env.to_s
  end

  should 'fallback to "?" when calling to_s with empty name' do
    env = Environment.new(:name => nil)
    assert_nil env.name
    assert_equal "?", env.to_s
  end

  should 'remove boxes and blocks when removing environment' do
    env = Environment.create!(:name => 'test environment')

    env_boxes = env.boxes.size
    env_blocks = env.blocks.size
    assert env_boxes > 0
    assert env_blocks > 0

    boxes = Box.count
    blocks = Block.count

    env.destroy

    assert_equal boxes - env_boxes, Box.count
    assert_equal blocks - env_blocks, Block.count
  end
  
  should 'have boxes and blocks upon creation' do
    environment = Environment.create!(:name => 'a test environment')
    assert environment.boxes.size > 0
    assert environment.blocks.size > 0
  end

  should 'have at least one MainBlock upon creation' do
    environment = Environment.create!(:name => 'a test environment')
    assert(environment.blocks.any? { |block| block.kind_of? MainBlock })
  end

  should 'provide recent_documents' do
    environment = Environment.create(:name => 'a test environment')

    p1 = environment.profiles.build(:identifier => 'testprofile1', :name => 'test profile 1'); p1.save!
    p2 = environment.profiles.build(:identifier => 'testprofile2', :name => 'test profile 2'); p2.save!

    # clear the articles
    Article.destroy_all

    # p1 creates one article
    doc1 = p1.articles.build(:name => 'text 1'); doc1.save!

    # p2 creates two articles
    doc2 = p2.articles.build(:name => 'text 2'); doc2.save!
    doc3 = p2.articles.build(:name => 'text 3'); doc3.save!

    # p1 creates another article
    doc4 = p1.articles.build(:name => 'text 4'); doc4.save!

    all_recent = environment.recent_documents
    [doc1,doc2,doc3,doc4].each do |item|
      assert_includes all_recent, item
    end

    last_three = environment.recent_documents(3)
    [doc2, doc3, doc4].each do |item|
      assert_includes last_three, item
    end
    assert_not_includes last_three, doc1

  end

  should 'have a description attribute' do
    env = Environment.new

    env.description = 'my fine environment'
    assert_equal 'my fine environment', env.description
  end

  should 'have admin role' do
    Role.expects(:find_by_key).with('environment_administrator').returns(Role.new)
    assert_kind_of Role, Environment::Roles.admin
  end

  should 'have products through enterprises' do
    env = Environment.default
    e1 = Enterprise.create!(:name => 'test_ent1', :identifier => 'test_ent1')
    p1 = e1.products.create!(:name => 'test_prod1')

    assert_includes env.products, p1
  end
  
  should 'not have person through communities' do
    env = Environment.default
    com = Community.create!(:identifier => 'community_1', :name => 'Community one')
    person = create_user('test_user').person
    assert_includes env.communities, com
    assert_not_includes env.communities, person
  end

  should 'not have person through enterprises' do
    env = Environment.default
    ent = Enterprise.create!(:identifier => 'enterprise_1', :name => 'Enterprise one')
    person = create_user('test_user').person
    assert_includes env.enterprises, ent
    assert_not_includes env.enterprises, person
  end

  should 'not have enterprises through people' do
    env = Environment.default
    person = create_user('test_user').person
    ent = Enterprise.create!(:identifier => 'enterprise_1', :name => 'Enterprise one')
    assert_includes env.people, person
    assert_not_includes env.people, ent
  end

end
