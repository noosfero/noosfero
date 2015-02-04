require_relative "../test_helper"

class ApproveCommentTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('test_user', :email => "someone@anyhost.com").person
    @article = fast_create(TextileArticle, :profile_id => @profile.id, :name => 'test name', :abstract => 'Lead of article', :body => 'This is my article')
    @community = create(Community, :contact_email => "someone@anyhost.com")
    @comment = build(Comment, :article => @article, :title => 'any comment', :body => "any text", :author => create_user('someperson').person)
  end

  attr_reader :profile, :article, :community

  should 'be a task' do
    ok { ApproveComment.new.kind_of?(Task) }
  end

  should 'comment method deserialize comment attributes' do
    a = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)
    assert_equal @comment.attributes, a.comment.attributes
  end

  should 'article method returns comment article' do
    @comment.article = @article
    a = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)
    assert_equal @article, @comment.article
  end

  should 'article method returns nil if comment.article if nil' do
    @comment.article = nil
    a = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)
    assert_nil @comment.article
  end

  should 'not raise in comment action if comment_attributes if nil' do
    a = ApproveComment.new(:comment_attributes => nil)
    assert_nothing_raised do
      a.comment
    end
  end

  should 'have article_name reference comment article' do
    approve_comment = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)

    assert_equal @article.name, approve_comment.article_name
  end

  should 'article_name be article removed if there is no article associated to comment' do
    @comment.article = nil
    approve_comment = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)

    assert_equal "Article removed.", approve_comment.article_name
  end

  should 'have linked_subject reference comment article' do
    approve_comment = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)

    expected =  {:text => @article.name, :url => @article.url}
    assert_equal expected, approve_comment.linked_subject
  end

  should 'have linked_subject ne nil if there is no article associated to comment' do
    @comment.article = nil
    approve_comment = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)

    assert_nil approve_comment.linked_subject
  end

  should 'create comment when finishing task' do
    approve_comment = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)
    assert_difference '@article.comments.count', 1 do
      approve_comment.finish
    end
  end

  should 'create comment with the created_at atribute passed as parameter when finishing task' do
    now = Time.now.in_time_zone - 10
    @comment.created_at = now
    approve_comment = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)
    assert_difference '@article.comments.count', 1 do
      approve_comment.finish
    end
    comment = Comment.last
    assert_equal now.to_s, comment.created_at.to_s
  end

  should 'require target (profile which the article is going to be commented)' do
    task = ApproveComment.new
    task.valid?

    ok('must not validate with empty target') { task.errors[:target_id.to_s].present? }

    task.target = Person.new
    task.valid?
    ok('must validate when target is given') { task.errors[:target_id.to_s].present?}
  end

  should 'send e-mails' do
    mailer = mock
    mailer.expects(:deliver).at_least_once
    TaskMailer.expects(:target_notification).returns(mailer).at_least_once

    task = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)

  end

   should 'override target notification message method from Task' do
    task = ApproveComment.new(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'deliver target notification message' do
    task = ApproveComment.new(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)

    email = TaskMailer.target_notification(task, task.target_notification_message).deliver
    assert_match(/\[#{task.environment.name}\] #{task.requestor.name} wants to comment the article: #{task.article_name}/, email.subject)
  end

  should 'alert when reference article is removed' do
    a = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)

    @article.destroy
    a.reload
    assert_equal "The article was removed.", a.information[:message]
  end

  should 'display anonymous name if the requestor is nil' do
    a = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => nil)

    assert_match /nonymous/, a.information[:variables][:requestor]
  end

  should 'accept_details be true' do
    a = ApproveComment.new
    assert a.accept_details
  end

  should 'reject_details be true' do
    a = ApproveComment.new
    assert a.reject_details
  end

  should 'default decision be skip if there is an article associated to task' do
    a = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)
    assert 'skip', a.default_decision
  end

  should 'default decision be reject if there is no article associated to task' do
    a = ApproveComment.new()
    assert 'reject', a.default_decision
  end

  should 'accept_disabled be true if there is no article associated to task' do
    a = ApproveComment.new
    assert a.accept_disabled?
  end

  should 'accept_disabled be false if there is an article associated to task' do
    a = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)
    assert !a.accept_disabled?
  end

  should 'have target notification description' do
    task = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)

    assert_match(/#{task.requestor.name} wants to comment the article: #{article.name}/, task.target_notification_description)
  end

  should 'have an target notification description for comments on removed articles' do
    task = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)

    @article.destroy
    assert_match(/#{task.requestor.name} wanted to comment the article but it was removed/, task.target_notification_description)
  end

  should 'have a default finished messsage after approval' do
    task = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)
    assert_match(/Your request for comment the article "#{task.article.title}" was approved/, task.task_finished_message)
  end

  should 'have a personalized finished messsage after approval' do
    task = ApproveComment.create!(:target => @community, :comment_attributes => @comment.attributes.to_json, :requestor => @profile)
    task.stubs(:closing_statment).returns('somenthing')

    assert_match(/Your .*#{task.article.title}.*Here is the comment.*\n\n#{task.closing_statment}/, task.task_finished_message)
  end

  should 'return reject message even without reject explanation' do
    task = ApproveComment.new
    assert_not_nil task.task_cancelled_message
  end

  should 'show the name of the article in the reject message' do
    task = ApproveComment.new(:comment_attributes => @comment.attributes.to_json)
    assert_match /Your request for commenting the article .*#{@article.name}.* was rejected/, task.task_cancelled_message
  end

  should 'return reject message with reject explanation' do
    task = ApproveComment.new
    task.reject_explanation= "Some reject explanation"
    assert_match(/Your request for commenting .* Here is the reject explanation .*\n\n#{task.reject_explanation}/, task.task_cancelled_message)
  end

  should 'requestor name be the name of the requestor' do
    a = fast_create(ApproveComment, :target_id => community, :requestor_id => profile)
    assert_equal profile.name, a.requestor_name
  end

  should 'requestor name be Anonymous if there is no requestor' do
    a = fast_create(ApproveComment, :target_id => community)
    a.comment_attributes = @comment.attributes.to_json
    assert_equal 'Anonymous', a.requestor_name
  end

end
