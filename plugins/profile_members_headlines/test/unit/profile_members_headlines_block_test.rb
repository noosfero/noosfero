require 'test_helper'

class ProfileMembersHeadlinesBlockTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = fast_create(Environment)
    @environment.enable_plugin(ProfileMembersHeadlinesPlugin)

    @member1 = fast_create(Person)
    @member2 = fast_create(Person)
    @community = fast_create(Community)
    community.add_member member1
    community.add_member member2
  end
  attr_accessor :environment, :community, :member1, :member2

  should 'inherit from Block' do
    assert_kind_of Block, ProfileMembersHeadlinesBlock.new
  end

  should 'describe itself' do
    assert_not_equal Block.description, ProfileMembersHeadlinesBlock.description
  end

  should 'provide a default title' do
    assert_not_equal Block.new.default_title, ProfileMembersHeadlinesBlock.new.default_title
  end

  should 'not have authors if they have no blog' do
    block = ProfileMembersHeadlinesBlock.create
    block.stubs(:owner).returns(community)

    self.expects(:render).with(:file => 'blocks/headlines', :locals => { :block => block, :members => []}).returns('file-without-authors-and-headlines')
    assert_equal 'file-without-authors-and-headlines', instance_eval(&block.content)
  end

  should 'display headlines file' do
    block = ProfileMembersHeadlinesBlock.create
    block.stubs(:owner).returns(community)
    blog = fast_create(Blog, :profile_id => member1.id)
    post = fast_create(TinyMceArticle, :name => 'headlines', :profile_id => member1.id, :parent_id => blog.id)
    self.expects(:render).with(:file => 'blocks/headlines', :locals => { :block => block, :members => []}).returns('file-with-authors-and-headlines')
    assert_equal 'file-with-authors-and-headlines', instance_eval(&block.content)
  end

  should 'select only authors with articles and selected roles to display' do
    role = Role.create!(:name => 'role1')
    community.affiliate(member1, role)
    block = ProfileMembersHeadlinesBlock.new(:limit => 1, :filtered_roles => [role.id])
    block.expects(:owner).returns(community)
    blog = fast_create(Blog, :profile_id => member1.id)
    post = fast_create(TinyMceArticle, :name => 'headlines', :profile_id => member1.id, :parent_id => blog.id)
    assert_equal [member1], block.authors_list
  end

  should 'not select private authors to display' do
    block = ProfileMembersHeadlinesBlock.new(:limit => 1)
    block.expects(:owner).returns(community)
    private_author = fast_create(Person, :public_profile => false)
    blog = fast_create(Blog, :profile_id => private_author.id)
    post = fast_create(TinyMceArticle, :name => 'headlines', :profile_id => private_author.id, :parent_id => blog.id)
    assert_equal [], block.authors_list
  end

  should 'filter authors by roles to display' do
    role = Role.create!(:name => 'role1')
    author = fast_create(Person)
    community.affiliate(author, role)

    block = ProfileMembersHeadlinesBlock.new(:limit => 3, :filtered_roles =>
[role.id])
    block.stubs(:owner).returns(community)
    community.members.each do |member|
      blog = fast_create(Blog, :profile_id => member.id)
      post = fast_create(TinyMceArticle, :name => 'headlines', :profile_id => member.id, :parent_id => blog.id)
    end
    assert_equal [author], block.authors_list
  end
end
