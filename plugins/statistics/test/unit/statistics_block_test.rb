require_relative '../test_helper'
class StatisticsBlockTest < ActiveSupport::TestCase

  ['user_counter', 'tag_counter', 'comment_counter'].map do |counter|
    should "#{counter} be true by default" do
      b = StatisticsBlock.new
      assert b.is_visible?(counter)
    end
  end

  ['community_counter', 'enterprise_counter', 'product_counter', 'category_counter', 'hit_counter'].map do |counter|
    should "#{counter} be false by default" do
      b = StatisticsBlock.new
      assert !b.is_visible?(counter)
    end
  end

  should 'inherit from Block' do
    assert_kind_of Block, StatisticsBlock.new
  end

  should 'provide a default title' do
    block = StatisticsBlock.new

    owner = mock
    owner.expects(:name).returns('my environment')
    block.expects(:owner).returns(owner)
    assert_equal 'Statistics for my environment', block.title
  end

  should 'describe itself' do
    assert_not_equal StatisticsBlock.description, Block.description
  end

  should 'is_visible? return true if setting is true' do
    b = StatisticsBlock.new
    b.community_counter = true
    assert b.is_visible?('community_counter')
  end

  should 'is_visible? return false if setting is false' do
    b = StatisticsBlock.new
    b.community_counter = false
    assert !b.is_visible?('community_counter')
  end

  should 'templates return the Community templates of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    t1 = fast_create(Community, :is_template => true, :environment_id => e.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => e.id)
    fast_create(Community, :is_template => false)

    b.expects(:owner).at_least_once.returns(e)

    t = b.templates
    assert_equal [], [t1,t2] - t
    assert_equal [], t - [t1,t2]
  end

  should 'users return the amount of users of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    fast_create(Person, :environment_id => e.id)
    fast_create(Person, :environment_id => e.id)
    fast_create(Person, :visible => false, :environment_id => e.id)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.users
  end

  should 'users return the amount of members of the community' do
    b = StatisticsBlock.new

    c1 = fast_create(Community)
    c1.add_member(fast_create(Person))
    c1.add_member(fast_create(Person))
    c1.add_member(fast_create(Person))
    c1.add_member(fast_create(Person, :visible => false))
    c1.add_member(fast_create(Person, :visible => false))

    b.expects(:owner).at_least_once.returns(c1)
    assert_equal 3, b.users
  end

  should 'users return the amount of friends of the person' do
    b = StatisticsBlock.new

    p1 = fast_create(Person)
    p1.add_friend(fast_create(Person))
    p1.add_friend(fast_create(Person))
    p1.add_friend(fast_create(Person))
    p1.add_friend(fast_create(Person, :visible => false))
    p1.add_friend(fast_create(Person, :visible => false))

    b.expects(:owner).at_least_once.returns(p1)
    assert_equal 3, b.users
  end

  should 'communities return the amount of communities of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    fast_create(Community, :environment_id => e.id)
    fast_create(Community, :environment_id => e.id)
    fast_create(Community, :visible => false, :environment_id => e.id)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.communities
  end

  should 'enterprises return the amount of enterprises of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    fast_create(Enterprise, :environment_id => e.id)
    fast_create(Enterprise, :environment_id => e.id)
    fast_create(Enterprise, :visible => false, :environment_id => e.id)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.enterprises
  end

  should 'return the amount of enabled enterprises' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    fast_create(Enterprise, :environment_id => e.id)
    fast_create(Enterprise, :environment_id => e.id)
    fast_create(Enterprise, :enabled => false, :environment_id => e.id)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.enterprises
  end

  should 'return the amount of visible environment products' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    e1 = fast_create(Enterprise, :visible => true, :enabled => true, :environment_id => e.id)
    e2 = fast_create(Enterprise, :visible => true, :enabled => false, :environment_id => e.id)
    e3 = fast_create(Enterprise, :visible => false, :enabled => true, :environment_id => e.id)

    fast_create(Product, :profile_id => e1.id)
    fast_create(Product, :profile_id => e1.id)
    fast_create(Product, :profile_id => e2.id)
    fast_create(Product, :profile_id => e2.id)
    fast_create(Product, :profile_id => e3.id)
    fast_create(Product, :profile_id => e3.id)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.products
  end

  should 'return the amount of visible enterprise products' do
    b = StatisticsBlock.new

    e = fast_create(Enterprise)

    fast_create(Product, :profile_id => e.id)
    fast_create(Product, :profile_id => e.id)
    fast_create(Product, :profile_id => nil)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.products
  end

  should 'categories return the amount of categories of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    fast_create(Category, :environment_id => e.id)
    fast_create(Category, :environment_id => e.id)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.categories
  end

  should 'tags return the amount of tags of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    p1 = fast_create(Person, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => p1.id)
    a1.tag_list.add('T1', 'T2')
    a1.save!
    a2 = fast_create(Article, :profile_id => p1.id)
    a2.tag_list.add('T3', 'T4')
    a2.save!

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 4, b.tags
  end

  should 'tags return the amount of tags of the community' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    c1 = fast_create(Community, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => c1.id)
    a1.tag_list.add('T1', 'T2')
    a1.save!
    a2 = fast_create(Article, :profile_id => c1.id)
    a2.tag_list.add('T3', 'T4')
    a2.save!

    b.expects(:owner).at_least_once.returns(c1)

    assert_equal 4, b.tags
  end

  should 'tags return the amount of tags of the profile (person)' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    p1 = fast_create(Person, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => p1.id)
    a1.tag_list.add('T1', 'T2')
    a1.save!
    a2 = fast_create(Article, :profile_id => p1.id)
    a2.tag_list.add('T3', 'T4')
    a2.save!

    b.expects(:owner).at_least_once.returns(p1)

    assert_equal 4, b.tags
  end

  should 'comments return the amount of comments of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    p1 = fast_create(Person, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => p1.id)

    Comment.create!(:source => a1, :body => 'C1', :author => p1)
    Comment.create!(:source => a1, :body => 'C2', :author => p1)

    a2 = fast_create(Article, :profile_id => p1.id)
    Comment.create!(:source => a2, :body => 'C3', :author => p1)
    Comment.create!(:source => a2, :body => 'C4', :author => p1)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 4, b.comments
  end

  should 'comments return the amount of comments of the community' do
    b = StatisticsBlock.new
    e = Environment.default

    p1 = fast_create(Person, :environment_id => e.id)
    c1 = fast_create(Community, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => c1.id)
    Comment.create!(:source => a1, :body => 'C1', :author => p1)
    Comment.create!(:source => a1, :body => 'C2', :author => p1)

    a2 = fast_create(Article, :profile_id => c1.id)
    Comment.create!(:source => a2, :body => 'C3', :author => p1)
    Comment.create!(:source => a2, :body => 'C4', :author => p1)

    b.expects(:owner).at_least_once.returns(c1)

    assert_equal 4, b.comments
  end

  should 'comments return the amount of comments of the profile (person)' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    p1 = fast_create(Person, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => p1.id)
    Comment.create!(:source => a1, :body => 'C1', :author => p1)
    Comment.create!(:source => a1, :body => 'C2', :author => p1)

    a2 = fast_create(Article, :profile_id => p1.id)
    Comment.create!(:source => a1, :body => 'C3', :author => p1)
    Comment.create!(:source => a1, :body => 'C4', :author => p1)

    b.expects(:owner).at_least_once.returns(p1)

    assert_equal 4, b.comments
  end

  should 'hits return the amount of hits of the Environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    p1 = fast_create(Person, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => p1.id, :hits => 2)
    a2 = fast_create(Article, :profile_id => p1.id, :hits => 5)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 7, b.hits
  end

  should 'hits return the amount of hits of the community' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    c1 = fast_create(Community, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => c1.id, :hits => 2)
    a2 = fast_create(Article, :profile_id => c1.id, :hits => 5)

    b.expects(:owner).at_least_once.returns(c1)

    assert_equal 7, b.hits
  end

  should 'hits return the amount of hits of the profile (person)' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    p1 = fast_create(Person, :environment_id => e.id)
    a1 = fast_create(Article, :profile_id => p1.id, :hits => 2)
    a2 = fast_create(Article, :profile_id => p1.id, :hits => 5)

    b.expects(:owner).at_least_once.returns(p1)

    assert_equal 7, b.hits
  end

  should 'is_counter_available? return true for all counters if owner is environment' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    b.expects(:owner).at_least_once.returns(e)

    assert b.is_counter_available?(:user_counter)
  end

  should 'is_template_counter_active? return true if setting is true' do
    b = StatisticsBlock.new
    b.templates_ids_counter = {'1' => 'true'}
    assert b.is_template_counter_active?(1)
  end

  should 'is_template_counter_active? return false if setting is false' do
    b = StatisticsBlock.new
    b.templates_ids_counter = {'1' => 'false'}
    assert !b.is_template_counter_active?(1)
  end

  should 'template_counter_count return the amount of communities of the Environment using a template' do
    b = StatisticsBlock.new
    e = fast_create(Environment)

    t1 = fast_create(Community, :is_template => true, :environment_id => e.id)
    t2 = fast_create(Community, :is_template => true, :environment_id => e.id)
    fast_create(Community, :is_template => false, :environment_id => e.id, :template_id => t1.id, :visible => true)
    fast_create(Community, :is_template => false, :environment_id => e.id, :template_id => t1.id, :visible => true)
    fast_create(Community, :is_template => false, :environment_id => e.id, :template_id => t1.id, :visible => false)

    fast_create(Community, :is_template => false, :environment_id => e.id, :template_id => t2.id, :visible => true)
    fast_create(Community, :is_template => false, :environment_id => e.id, :template_id => t2.id, :visible => false)

    b.expects(:owner).at_least_once.returns(e)

    assert_equal 2, b.template_counter_count(t1.id)
  end
end
