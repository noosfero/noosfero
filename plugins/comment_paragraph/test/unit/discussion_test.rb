require_relative '../test_helper'

class DiscussionTest < ActiveSupport::TestCase

  def setup
    @profile = fast_create(Community)
    @discussion = fast_create(TextArticle, :profile_id => profile.id)
    @environment = Environment.default
    @environment.enable_plugin(CommentParagraphPlugin)
  end

  attr_reader :discussion, :environment, :profile

  should 'not allow comments after end date' do
    discussion = CommentParagraphPlugin::Discussion.create!(profile: profile, name: "discussion", start_date: Time.now - 2.days, end_date: Time.now - 1.day)
    assert !discussion.accept_comments?
  end

  should 'not allow comments before start date' do
    discussion = CommentParagraphPlugin::Discussion.create!(profile: profile, name: "discussion", start_date: Time.now + 1.day, end_date: Time.now + 2.days)
    assert !discussion.accept_comments?
  end

  should 'have can_display_blocks with default false' do
    assert !CommentParagraphPlugin::Discussion.can_display_blocks?
  end
end
