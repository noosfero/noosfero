require_relative '../test_helper'
class DiscussionBlockTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(CommentParagraphPlugin)
  end

  attr_reader :environment

  should 'describe itself' do
    assert_not_equal Block.description, CommentParagraphPlugin::DiscussionBlock.description
  end

  should 'holder be nil if there is no box' do
    b = CommentParagraphPlugin::DiscussionBlock.new
    assert_nil b.holder
  end

  should 'holder be nil if there is no box owner to the box' do
    b = CommentParagraphPlugin::DiscussionBlock.new
    box = Box.new
    b.box = box
    assert_nil b.holder
  end

  should 'holder be nil if there is no portal community in environment' do
    b = CommentParagraphPlugin::DiscussionBlock.new
    environment.boxes<< Box.new
    b.box = environment.boxes.last
    assert_nil environment.portal_community
    assert_nil b.holder
  end

  should 'holder be the portal community for environments blocks' do
    community = fast_create(Community)
    environment.portal_community= community
    environment.save!
    environment.boxes<< Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = environment.boxes.last
    assert_equal environment.portal_community, b.holder
  end

  should 'holder be the person for people blocks' do
    person = fast_create(Person)
    person.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = person.boxes.last
    assert_equal person, b.holder
  end

  should 'holder be the community for communities blocks' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    assert_equal community, b.holder
  end

  should 'holder be the enterprise for enterprises blocks' do
    enterprise = fast_create(Enterprise)
    enterprise.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = enterprise.boxes.last
    assert_equal enterprise, b.holder
  end

  should 'discussions return only discussion articles' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    b.save
    a1 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id)
    fast_create(Event, :profile_id => community.id)
    fast_create(TextArticle, :profile_id => community.id)
    a2 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id)
    assert_equivalent [a1, a2], b.discussions
  end

  should 'return only not opened discussions if discussion status is not opened' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    b.discussion_status = CommentParagraphPlugin::DiscussionBlock::STATUS_NOT_OPENED
    b.save
    a1 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now + 1.day)
    a2 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now )
    a3 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now - 1.day)
    a4 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now - 2.day, :end_date => DateTime.now - 1.day)
    assert_equivalent [a1], b.discussions
  end

  should 'return only available discussions if discussion status is available' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    b.discussion_status = CommentParagraphPlugin::DiscussionBlock::STATUS_AVAILABLE
    b.save
    a1 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now + 1.day)
    a2 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now )
    a3 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now - 1.day)
    a4 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now - 2.day, :end_date => DateTime.now - 1.day)
    a5 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :end_date => DateTime.now + 1.day)
    assert_equivalent [a2, a3, a5], b.discussions
  end

  should 'return only closed discussions if discussion status is closed' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    b.discussion_status = CommentParagraphPlugin::DiscussionBlock::STATUS_CLOSED
    b.save
    a1 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now + 1.day)
    a2 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now )
    a3 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now - 1.day)
    a4 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, :start_date => DateTime.now - 2.day, :end_date => DateTime.now - 1.day)
    assert_equivalent [a4], b.discussions
  end

end

require 'boxes_helper'

class DiscussionBlockViewTest < ActionView::TestCase
  include BoxesHelper

  should 'show the title and the child titles when the block is set to title only mode' do
    profile = create_user('testuser').person

    block = CommentParagraphPlugin::DiscussionBlock.new
    block.stubs(:holder).returns(profile)
    block.presentation_mode = 'title_only'

    ActionView::Base.any_instance.stubs(:block_title).returns("Block Title")
    ActionView::Base.any_instance.stubs(:profile).returns(profile)

    content = render_block_content(block)

    assert_match /discussion-title/, content
    assert_no_match /discussion-abstract/, content
  end

  should 'show the title and the child titles and abstracts when the block is set to title and abstract mode' do
    profile = create_user('testuser').person

    block = CommentParagraphPlugin::DiscussionBlock.new
    block.stubs(:holder).returns(profile)
    block.presentation_mode = 'title_and_abstract'

    ActionView::Base.any_instance.stubs(:block_title).returns("Block Title")
    ActionView::Base.any_instance.stubs(:profile).returns(profile)

    content = render_block_content(block)

    assert_match /discussion-abstract/, content
  end

  should 'show the title and the child full content when the block has no mode set' do
    profile = create_user('testuser').person

    block = CommentParagraphPlugin::DiscussionBlock.new
    block.stubs(:holder).returns(profile)
    block.presentation_mode = ''

    ActionView::Base.any_instance.stubs(:block_title).returns("Block Title")
    ActionView::Base.any_instance.stubs(:profile).returns(profile)

    content = render_block_content(block)

    assert_match /discussion-full/, content
  end

  should 'return discussions in api_content' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    b.save
    a1 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id)
    fast_create(Event, :profile_id => community.id)
    fast_create(TextArticle, :profile_id => community.id)
    a2 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id)
    assert_equivalent [a2.id, a1.id], b.api_content['articles'].map {|a| a[:id]}
  end

  should 'sort discussions by start_date, end_date and created_at' do
    community = fast_create(Community)
    community.boxes << Box.new
    b = CommentParagraphPlugin::DiscussionBlock.new
    b.box = community.boxes.last
    b.save
    a1 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, start_date: Time.now)
    a2 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, start_date: Time.now + 1, end_date: Time.now)
    a3 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, start_date: Time.now + 1, end_date: Time.now + 1.day)
    a4 = fast_create(CommentParagraphPlugin::Discussion, :profile_id => community.id, start_date: Time.now + 1, end_date: Time.now + 1.day)
    assert_equal [a1.id, a2.id, a3.id, a4.id], b.discussions.map(&:id)
  end

end
