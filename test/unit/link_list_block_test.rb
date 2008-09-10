require File.dirname(__FILE__) + '/../test_helper'

class LinkListBlockTest < ActiveSupport::TestCase

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
    l.expects(:links).returns([{:name => 'products', :address => '/cat/products'}])
    assert_match /products/, l.content
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
    assert_tag_in_string l.content, :tag => 'a', :attributes => {:href => '/test_profile/address'}
  end

end
