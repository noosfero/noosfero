require File.dirname(__FILE__) + '/../../../../test/test_helper'

class CommentTest < ActiveSupport::TestCase
  should 'create a publication after posting a comment' do
    article = fast_create(Article, :profile_id => fast_create(Person).id)
    comment = Comment.new(:author_id => fast_create(Person).id, :body => 'Hello There!', :source_id => article.id)
    assert_difference ToleranceTimePlugin::Publication, :count do
      comment.save!
    end
    assert_not_nil ToleranceTimePlugin::Publication.find_by_target(comment)
  end

  should 'destroy publication if the comment is destroyed' do
    profile = fast_create(Profile)
    article = fast_create(Article, :profile_id => profile.id)
    comment = fast_create(Comment, :source_id => article.id)
    comment_publication = ToleranceTimePlugin::Publication.create!(:target => comment)
    comment.destroy
    assert_raise ActiveRecord::RecordNotFound do
      comment_publication.reload
    end
  end
end

