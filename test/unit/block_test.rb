require_relative "../test_helper"

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
    assert_equal false, build(Block, :display => 'never').visible?
    assert_equal false, build(Block, :display => 'never').visible?(:article => Article.new)
  end

  should 'be able to be displayed only in the homepage' do
    profile = Profile.new
    home_page = Article.new
    profile.home_page = home_page
    block = build(Block, :display => 'home_page_only')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:article => home_page)
    assert_equal false, block.visible?(:article => Article.new)
  end

  should 'be able to be displayed only in the homepage (index) of the environment' do
    block = build(Block, :display => 'home_page_only')

    assert_equal true, block.visible?(:article => nil, :request_path => "#{Noosfero.root('/')}")
    assert_equal false, block.visible?(:article => nil)
  end

  should 'be able to be displayed everywhere except in the homepage' do
    profile = Profile.new
    home_page = Article.new
    profile.home_page = home_page
    block = build(Block, :display => 'except_home_page')
    block.stubs(:owner).returns(profile)

    assert_equal false, block.visible?(:article => home_page)
    assert_equal true, block.visible?(:article => Article.new)
  end

  should 'be able to be displayed everywhere except on profile index' do
    profile = build(Profile, :identifier => 'testinguser')
    block = build(Block, :display => 'except_home_page')
    block.stubs(:owner).returns(profile)

    assert_equal false, block.visible?(:article => nil, :request_path => "#{Noosfero.root('/')}profile/testinguser")
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
    block = build(Block, :language => 'all')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:locale => 'pt')
    assert_equal true, block.visible?(:locale => 'en')
  end

  should 'be able to be displayed only in the selected language' do
    profile = Profile.new
    block = build(Block, :language => 'pt')
    block.stubs(:owner).returns(profile)

    assert_equal true, block.visible?(:locale => 'pt')
    assert_equal false, block.visible?(:locale => 'en')
  end

  should 'delegate environment to box' do
    box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = build(Block, :box => box)
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
    assert_difference 'Block.count', 1 do
      block.duplicate
    end
  end

  should 'clone and keep some fields' do
    box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = create(TagsBlock, :title => 'test 1', :box_id => box.id, :settings => {:test => 'test'})
    duplicated = block.duplicate
    [:title, :box_id, :type].each do |f|
      assert_equal duplicated.send(f), block.send(f)
    end
    assert 'test', duplicated[:settings][:test]
  end

  should 'clone block and set fields' do
    box = fast_create(Box, :owner_id => fast_create(Profile).id)
    block = create(TagsBlock, :title => 'test 1', :box_id => box.id, :settings => {:test => 'test'}, :position => 1)
    block2 = create(TagsBlock, :title => 'test 2', :box_id => box.id, :settings => {:test => 'test'}, :position => 2)
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
    block = create(TagsBlock, :title => 'test 1', :box_id => box.id, :settings => {:test => 'test'}, :position => 1)
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
        context[:value] % 2 == 0
      end
    end

    block = MyBlock.new

    assert block.visible?({:value => 2})
    assert !block.visible?({:value => 3})
  end

  should 'not be embedable by default' do
    assert !Block.new.embedable?
  end

  should 'generate embed code' do
    b = Block.new
    b.stubs(:url_for).returns('http://myblogtest.com/embed/block/1')
    assert_equal "<iframe class=\"embed block block\" frameborder=\"0\" height=\"768\" src=\"http://myblogtest.com/embed/block/1\" width=\"1024\"></iframe>", b.embed_code.call
  end

  should 'default value for display_user is all' do
    block = Block.new
    assert_equal 'all', block.display_user
  end

  should 'display block to not logged users for display_user = all' do
    block = Block.new
    assert block.display_to_user?(nil)
  end

  should 'display block to logged users for display_user = all' do
    block = Block.new
    assert block.display_to_user?(User.new)
  end

  should 'display block to logged users for display_user = logged' do
    block = Block.new
    block.display_user = 'logged'
    assert block.display_to_user?(User.new)
  end

  should 'do not display block to logged users for display_user = not_logged' do
    block = Block.new
    block.display_user = 'not_logged'
    assert !block.display_to_user?(User.new)
  end

  should 'do not display block to not logged users for display_user = logged' do
    block = Block.new
    block.display_user = 'logged'
    assert !block.display_to_user?(nil)
  end

  should 'display block to not logged users for display_user = not_logged' do
    block = Block.new
    block.display_user = 'not_logged'
    assert block.display_to_user?(nil)
  end

  should 'not be visible if display_to_user? is false' do
    block = Block.new
    block.expects(:display_to_user?).once.returns(false)
    assert !block.visible?({})
  end

  should 'accept user as parameter on cache_key without change its value' do
    person = fast_create(Person)
    block = Block.new
    assert_equal block.cache_key('en'), block.cache_key('en', person)
  end

  should 'display block to members of community for display_user = members' do
    community = fast_create(Community)
    user = create_user('testinguser')
    community.add_member(user.person)

    box = fast_create(Box, :owner_id => community.id, :owner_type => 'Community')
    block = create(Block, :box_id => box.id)
    block.display_user = 'followers'
    block.save!
    assert block.display_to_user?(user.person)
  end

  should 'do not display block to non members of community for display_user = members' do
    community = fast_create(Community)
    user = create_user('testinguser')

    box = fast_create(Box, :owner_id => community.id, :owner_type => 'Community')
    block = create(Block, :box_id => box.id)
    block.display_user = 'followers'
    block.save!
    assert !block.display_to_user?(user.person)
  end

  should 'display block to friends of person for display_user = friends' do
    person = create_user('person_one').person
    person_friend = create_user('person_friend').person

    person.add_friend(person_friend)

    box = fast_create(Box, :owner_id => person.id, :owner_type => 'Person')
    block = create(Block, :box_id => box.id)
    block.display_user = 'followers'
    block.save!
    assert block.display_to_user?(person_friend)
  end

  should 'do not display block to non friends of person for display_user = friends' do
    person = create_user('person_one').person
    person_friend = create_user('person_friend').person

    box = fast_create(Box, :owner_id => person.id, :owner_type => 'Person')
    block = create(Block, :box_id => box.id)
    block.display_user = 'followers'
    block.save!
    assert !block.display_to_user?(person_friend)
  end
end
