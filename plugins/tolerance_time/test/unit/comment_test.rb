require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  should 'create a publication after posting a comment' do
    article = fast_create(Article, :profile_id => fast_create(Person).id)
    comment = Comment.new(:author => fast_create(Person), :body => 'Hello There!', :source => article)
    assert_difference 'ToleranceTimePlugin::Publication.count', 1 do
      comment.save!
    end
    assert_not_nil ToleranceTimePlugin::Publication.find_by_target(comment)
  end

  should 'destroy publication if the comment is destroyed' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    comment = fast_create(Comment, :source_id => article)
    comment_publication = ToleranceTimePlugin::Publication.create!(:target => comment)
    comment.destroy
    assert_raise ActiveRecord::RecordNotFound do
      comment_publication.reload
    end
  end
end

