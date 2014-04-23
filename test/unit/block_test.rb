require File.dirname(__FILE__) + '/../test_helper'

class BlockTest < ActiveSupport::TestCase


  should 'describe itself' do
    assert_kind_of String, Block.description
  end
  
  should 'access owner through box' do
    user = create_user('testinguser').person

    box = fast_create(Box, :owner_id => user, :owner_type => 'Person')

    block = Block.new
    block.box = box
    block.save!

    assert_equal user, block.owner
  end

  should 'have no owner when there is no box' do
    assert_nil Block.new.owner
  end

  should 'provide no footer by default' do
    assert_nil Block.new.footer
  end

  should 'provide an empty default title' do
    assert_equal '', Block.new.default_title
  end

  should 'be editable by default' do
    assert Block.new.editable?
  end

  should 'have default titles' do
    b = Block.new
    b.expects(:default_title).returns('my title')
    assert_equal 'my title', b.title
  end

  should 'have default view_title ' do
    b = Block.new
    b.expects(:title).returns('my title')
    assert_equal 'my title', b.view_title
  end

  should 'be cacheable' do
    b = Block.new
    assert b.cacheable?
  end

  should 'list enabled blocks' do
    block1 = fast_create(Block, :title => 'test 1')
    block2 = fast_create(Block, :title => 'test 2', :enabled => false)
    assert_includes Block.enabled, block1
    assert_not_includes Block.enabled, block2
  end

  should 'be displayed everywhere by default' do
    assert_equal true, Block.new.visible?
  end

  should 'not display when set to hidden' do
    assert_equal false, Block.new(:display => 'never').visible?
    assert_equal false, Block.new(:display => 'never').visible?(:article => Article.new)
  end

  should 'be able to be displayed only in the homepage' do
    profile = Profile.new
    home_page = Article.new
    profile.home_page = home_page
    block = Block.new(:display => 'home_page_only')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:article => home_page)
    assert_equal false, block.visible?(:article => Article.new)
  end

  should 'be able to be displayed only in the homepage (index) of the environment' do
    block = Block.new(:display => 'home_page_only')

    assert_equal true, block.visible?(:article => nil, :request_path => '/')
    assert_equal false, block.visible?(:article => nil)
  end

  should 'be able to be displayed everywhere except in the homepage' do
    profile = Profile.new
    home_page = Article.new
    profile.home_page = home_page
    block = Block.new(:display => 'except_home_page')
    block.stubs(:owner).returns(profile)

    assert_equal false, block.visible?(:article => home_page)
    assert_equal true, block.visible?(:article => Article.new)
  end

  should 'be able to be displayed everywhere except on profile index' do
    profile = Profile.new(:identifier => 'testinguser')
    block = Block.new(:display => 'except_home_page')
    block.stubs(:owner).returns(profile)

    assert_equal false, block.visible?(:article => nil, :request_path => '/testinguser')
    assert_equal true, block.visible?(:article => nil)
  end

  should 'be able to save display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id, :owner_type => 'Profile')
    block = create(Block, :display => 'never', :box_id => box.id)
    block.reload
    assert_equal 'never', block.display
  end

  should 'be able to update display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id, :owner_type => 'Profile')
    block = create(Block, :display => 'never', :box_id => box.id)
    assert block.update_attributes!(:display => 'always')
    block.reload
    assert_equal 'always', block.display
  end

  should 'display block in all languages by default' do
    profile = Profile.new
    block = Block.new
    block.stubs(:owner).returns(profile)

    assert_equal 'all', block.language
  end

  should 'be able to be displayed in all languages' do
    profile = Profile.new
    block = Block.new(:language => 'all')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:locale => 'pt')
    assert_equal true, block.visible?(:locale => 'en')
  end

  should 'be able to be displayed only in the selected language' do
    profile = Profile.new
    block = Block.new(:language => 'pt')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:locale => 'pt')
    assert_equal false, block.visible?(:locale => 'en')
  end

  should 'delegate environment to box' do
    box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = Block.new(:box => box)
    box.stubs(:environment).returns(Environment.default)

    assert_equal box.environment, block.environment
  end

  should 'inform conditions for expiration on profile context' do
    conditions = Block.expire_on
    assert conditions[:profile].kind_of?(Array)
  end

  should 'inform conditions for expiration on environment context' do
    conditions = Block.expire_on
    assert conditions[:environment].kind_of?(Array)
  end

  should 'create a cloned block' do
    block = fast_create(Block, :title => 'test 1', :position => 1)
    assert_difference Block, :count, 1 do
      block.duplicate
    end
  end

  should 'clone and keep some fields' do
    box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = TagsBlock.create!(:title => 'test 1', :box_id => box.id, :settings => {:test => 'test'})
    duplicated = block.duplicate
    [:title, :box_id, :type].each do |f|
      assert_equal duplicated.send(f), block.send(f)
    end
    assert 'test', duplicated[:settings][:test]
  end

  should 'clone block and set fields' do
    box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = TagsBlock.create!(:title => 'test 1', :box_id => box.id, :settings => {:test => 'test'}, :position => 1)
    block2 = TagsBlock.create!(:title => 'test 2', :box_id => box.id, :settings => {:test => 'test'}, :position => 2)
    duplicated = block.duplicate
    block2.reload
    block.reload
    assert_equal 'never', duplicated.display
    assert_equal 1, block.position
    assert_equal 2, duplicated.position
    assert_equal 3, block2.position
  end

  should 'not clone date creation and update attributes' do
     box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = TagsBlock.create!(:title => 'test 1', :box_id => box.id, :settings => {:test => 'test'}, :position => 1)
    duplicated = block.duplicate

      assert_not_equal block.created_at, duplicated.created_at
      assert_not_equal block.updated_at, duplicated.updated_at
  end

  should 'support custom display options for blocks visible' do
    class MyBlock < Block
      def display
        'even_context'
      end

      def display_even_context(context)
        context % 2 == 0
      end
    end

    block = MyBlock.new

    assert block.visible?(2)
    assert !block.visible?(3)
  end

  should 'accept user as parameter on cache_key without change its value' do
    person = fast_create(Person)
    block = Block.new
    assert_equal block.cache_key('en'), block.cache_key('en', person)
  end

end
