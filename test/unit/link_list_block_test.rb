require_relative "../test_helper"

class LinkListBlockTest < ActiveSupport::TestCase

  include BoxesHelper

  should 'default describe' do
    assert_not_equal Block.description, LinkListBlock.description
  end

  should 'have field links' do
    l = LinkListBlock.new
    assert_respond_to l, :links
  end

  should 'default value of links' do
    l = LinkListBlock.new
    assert_equal [], l.links
  end

  should 'is editable' do
    l = LinkListBlock.new
    assert l.editable?
  end

  should 'list links' do
    l = LinkListBlock.new(:links => [{:name => 'products', :address => '/cat/products'}])
    assert_match /products/, render_block_content(l)
  end

  should 'remove links with blank fields' do
    l = LinkListBlock.new(:links => [{:name => 'categ', :address => '/address'}, {:name => '', :address => ''}])
    l.save!
    assert_equal [{:name => 'categ', :address => '/address'}], l.links
  end

  should 'replace {profile} with profile identifier' do
    profile = Profile.new(:identifier => 'test_profile')
    l = LinkListBlock.new(:links => [{:name => 'categ', :address => '/{profile}/address'}])
    l.stubs(:owner).returns(profile)
    assert_tag_in_string render_block_content(l), :tag => 'a', :attributes => {:href => '/test_profile/address'}
  end

  should 'replace {portal} with environment portal identifier' do
    env = Environment.default
    env.enable('use_portal_community')
    portal = fast_create(Community, :identifier => 'portal-community', :environment_id => env.id)
    env.portal_community = portal
    env.save

    stubs(:environment).returns(env)
    l = LinkListBlock.new(:links => [{:name => 'categ', :address => '/{portal}/address'}])
    l.stubs(:owner).returns(env)
    assert_tag_in_string render_block_content(l), :tag => 'a', :attributes => {:href => '/portal-community/address'}
  end

  should 'not change address if no {portal} there' do
    env = Environment.default
    env.enable('use_portal_community')
    portal = fast_create(Community, :identifier => 'portal-community', :environment_id => env.id)
    env.portal_community = portal
    env.save

    stubs(:environment).returns(env)
    l = LinkListBlock.new(:links => [{:name => 'categ', :address => '/address'}])
    l.stubs(:owner).returns(env)
    assert_tag_in_string render_block_content(l), :tag => 'a', :attributes => {:href => '/address'}
  end

  should 'handle /prefix if not already added' do
    Noosfero.stubs(:root).returns('/prefix')
    l = LinkListBlock.new(:links => [{:name => "foo", :address => '/bar'}] )
    assert_tag_in_string render_block_content(l), :tag => 'a', :attributes => { :href => '/prefix/bar' }
  end

  should 'not add /prefix if already there' do
    Noosfero.stubs(:root).returns('/prefix')
    l = LinkListBlock.new(:links => [{:name => "foo", :address => '/prefix/bar'}] )
    assert_tag_in_string render_block_content(l), :tag => 'a', :attributes => { :href => '/prefix/bar' }
  end

  should 'display options for icons' do
    l = LinkListBlock.new
    l.icons_options.each do |option|
      assert_match(/<span title=\".+\" class=\"icon-.+\" onclick=\"changeIcon\(this, '.+'\)\"><\/span>/, option)
    end
  end

  should 'link with icon' do
    l = LinkListBlock.new(:links => [{:icon => 'save', :name => 'test', :address => 'test.com'}])
    assert_match /a class="icon-[^"]+"/, render_block_content(l)
  end

  should 'no class without icon' do
    l = LinkListBlock.new(:links => [{:icon => nil, :name => 'test', :address => 'test.com'}])
    assert_no_match /a class="icon-[^"]+"/, render_block_content(l)
  end

  should 'not add link to javascript' do
    l = LinkListBlock.new(:links => [{:name => 'link', :address => "javascript:alert('Message test')"}])
    assert_no_match /href="javascript/, render_block_content(l)
  end

  should 'not add link to onclick' do
    l = LinkListBlock.new(:links => [{:name => 'link', :address => "#\" onclick=\"alert(123456)"}])
    assert_no_tag_in_string render_block_content(l), :attributes => { :onclick => /.*/ }
  end

  should 'add protocol in front of incomplete external links' do
    {'/local/link' => '/local/link', 'http://example.org' => 'http://example.org', 'example.org' => '//example.org'}.each do |input, output|
      l = LinkListBlock.new(:links => [{:name => 'categ', :address => input}])
      assert_tag_in_string render_block_content(l), :tag => 'a', :attributes => {:href => output}
    end
  end

  should 'be able to update display setting' do
    user = create_user('testinguser').person
    box = fast_create(Box, :owner_id => user.id)
    block = LinkListBlock.new(:display => 'never').tap do |b|
      b.box = box
    end
    assert block.update!(:display => 'always')
    block.reload
    assert_equal 'always', block.display
  end

  should 'have options for links target' do
    assert_equivalent LinkListBlock::TARGET_OPTIONS.map {|t|t[1]}, ['_self', '_blank', '_new']
  end

  should 'link with title' do
    l = LinkListBlock.new
    l = LinkListBlock.new(:links => [{:name => 'mylink', :address => '/myaddress', :title => 'mytitle'}])
    assert_match /title="mytitle"/, render_block_content(l)
  end

  should 'display default message to brand new blocks with no links' do
    l = LinkListBlock.new
    assert_match /Please, edit this block to add links/, render_block_content(l)
  end

end
