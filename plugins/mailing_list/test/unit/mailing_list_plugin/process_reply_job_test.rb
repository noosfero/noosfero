require 'test_helper'

class MailingListPlugin::ProcessReplyJobTest < ActiveSupport::TestCase

  def setup
    @user = create_user
    @article = fast_create(Article, author_id: @user.person.id)
    @comment = fast_create(Comment, author_id: @user.person.id,
                           source_id: @article.id)
    @article_uuid = SecureRandom.uuid
    @comment_uuid = SecureRandom.uuid

    Noosfero::Plugin::Metadata.new(@article, MailingListPlugin,
                                   { uuid: @article_uuid }).save!
    Noosfero::Plugin::Metadata.new(@comment, MailingListPlugin,
                                   { uuid: @comment_uuid }).save!
  end

  should 'create a comment on an article if uuid belongs to article' do
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, @article_uuid,
                                                 'Not empty.')
    assert_difference '@article.comments.count' do
      job.perform
    end
  end

  should 'create a reply on a comment if uuid belongs to comment' do
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, @comment_uuid,
                                                 'Not empty.')
    assert_difference '@comment.replies.count' do
      job.perform
    end
  end

  should 'create a task if the comments are moderated' do
    Comment.any_instance.stubs(:need_moderation?).returns(true)
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, @article_uuid,
                                                 'Not empty.')
    ApproveComment.expects(:create!).once
    job.perform
  end

  should 'not create a comment if message is blank' do
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, 'uuid', nil)
    assert_no_difference 'Comment.count' do
      job.perform
    end
  end

  should 'not create a comment if uuid is blank' do
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, nil, 'Not empty')
    assert_no_difference 'Comment.count' do
      job.perform
    end
  end

  should 'not create a comment if uuid is not valid' do
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, 'invalid', 'Not empty')
    assert_no_difference 'Comment.count' do
      job.perform
    end
  end

  should 'not create a comment if author does not exist' do
    job = MailingListPlugin::ProcessReplyJob.new('invalid@mail.com', @article_uuid, 'Not empty')
    assert_no_difference 'Comment.count' do
      job.perform
    end
  end

  should 'not create a comment if the target article/comment does not exist' do
    uuid = SecureRandom.uuid
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, uuid, 'Not empty')
    assert_no_difference 'Comment.count' do
      job.perform
    end
  end

  should 'not create a comment if the article does not accept comments' do
    Article.any_instance.stubs(:accept_comments?).returns(false)
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, @article_uuid,
                                                 'Not empty.')
    assert_no_difference '@article.comments.count' do
      job.perform
    end
  end

  should 'not create a comment if it is from the admin' do
    Noosfero::Plugin::Settings.any_instance.stubs(:administrator_email)
                                           .returns(@user.email)
    job = MailingListPlugin::ProcessReplyJob.new(@user.email, @article_uuid,
                                                 'Not empty.')
    assert_no_difference '@article.comments.count' do
      job.perform
    end
  end

end
