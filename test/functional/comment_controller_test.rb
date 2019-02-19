require_relative '../test_helper'

class CommentControllerTest < ActionDispatch::IntegrationTest

  def setup
    @profile = create_user('testinguser').person
    @environment = @profile.environment
  end
  attr_reader :profile, :environment

  should "not be able to remove other people's comments if not moderator or admin" do
    create_user('normaluser')
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'normaluser' # normaluser cannot remove other people's comments
    assert_no_difference 'Comment.count' do
      post destroy_comment_path(profile.identifier, comment)
    end
  end

  should "not be able to remove other people's comments if not moderator or admin and return json if is an ajax request" do
    create_user('normaluser')
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'normaluser' # normaluser cannot remove other people's comments
    assert_no_difference 'Comment.count' do
      post destroy_comment_path(profile.identifier, comment), xhr: true
      assert_response :success
    end
    assert_match /\{\"ok\":false\}/, @response.body
  end

  should 'be able to remove comments on their articles' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'testuser' # testuser must be able to remove comments in his articles
    assert_difference 'Comment.count', -1 do
      post destroy_comment_path(profile.identifier, comment), xhr: true
      assert_response :success
    end
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'be able to remove comments of their images' do
    profile = create_user('testuser').person

    image = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))
    image.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => image, :author_id => commenter, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'testuser' # testuser must be able to remove comments in his articles
    assert_difference 'Comment.count', -1 do
      post destroy_comment_path(profile.identifier, comment), xhr: true
      assert_response :success
    end
  end

  should 'be able to remove comments if is moderator' do
    commenter = create_user('commenter_user').person
    community = Community.create!(:name => 'Community test', :identifier => 'community-test')
    article = community.articles.create!(:name => 'test', :profile => community)
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')
    community.add_moderator(profile)
    login_as_rails5 profile.identifier
    assert_difference 'Comment.count', -1 do
      post destroy_comment_path(community.identifier, comment), xhr: true
      assert_response :success
    end
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'be able to remove comment' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'testuser'
    assert_difference 'Comment.count', -1 do
      post destroy_comment_path(profile.identifier, comment), xhr: true
      assert_response :success
    end
  end

  should 'display not found page if a user should try to make a cross comment' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    other_person = create_user('otheruser').person
    other_page = other_person.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    assert_no_difference 'Comment.count' do
      post comment_index_path(profile.identifier), params: {:comment => { :title => 'crap!', :body => 'I think that this article is crap' }, id: other_page.id}, xhr: true
    end
     assert_match /not found/, @response.body
  end

  should 'not be able to post comment if article do not accept it' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text', :accept_comments => false)

    assert_no_difference 'Comment.count' do
      post comment_index_path(profile.identifier), params: {:comment => { :title => 'crap!', :body => 'I think that this article is crap' }, id: page.id}, xhr: true
    end
     assert_match /Comment not allowed in this article/, @response.body
  end

  should "the author's comment be the logged user" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    login_as_rails5 profile.identifier

    post comment_index_path(profile.identifier), params: {:comment => { :title => 'crap!', :body => 'I think that this article is crap' }, id: page.id}, xhr: true
    assert_equal profile, assigns(:comment).author
  end

  should "the articles's comment be the article passed as parameter" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    login_as_rails5 profile.identifier

    post comment_index_path(profile.identifier), params: {:comment => { :title => 'crap!', :body => 'I think that this article is crap' }, id: page.id}, xhr: true
    assert_equal page, assigns(:comment).article
  end

  should 'show validation error when body comment is missing' do
    login_as_rails5 @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post comment_index_path(@profile.identifier), params: {:comment => { :title => '', :body => '' }, :confirm => 'true', id: page.id}, xhr: true
    response = ActiveSupport::JSON.decode @response.body
    assert_match /errorExplanation/, response["html"]
  end

  should 'not save a comment if a plugin rejects it' do
    class TestFilterPlugin < Noosfero::Plugin
      def filter_comment(c)
        c.reject!
      end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestFilterPlugin.new])
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    assert_no_difference 'Comment.count' do
      post comment_index_path(profile.identifier), params: {:comment => { :title => 'title', :body => 'body', :name => "Spammer", :email => 'damn@spammer.com' }, :confirm => 'true', id: page.id}, xhr: true
    end
  end

  should 'display a message if a plugin reject the comment' do
    class TestFilterPlugin < Noosfero::Plugin
      def filter_comment(c)
        c.reject!
      end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestFilterPlugin.new])
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    assert_no_difference 'Comment.count' do
      post comment_index_path(profile.identifier), params: {:comment => { :title => 'title', :body => 'body', :name => "Spammer", :email => 'damn@spammer.com' }, :confirm => 'true', id: page.id}, xhr: true
    end

    assert_match /rejected/, @response.body
  end

  should 'store IP address, user agent and referrer for comments' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post comment_index_path(profile.identifier), params: {:comment => { :title => 'title', :body => 'body', :name => "Spammer", :email => 'damn@spammer.com' }, :confirm => 'true', id: page.id}, xhr: true, headers: { "HTTP_REFERER" => "http://example.com", 'REMOTE_ADDR' => '33.44.55.66', 'HTTP_USER_AGENT': 'MyBrowser' }
    comment = Comment.last
    assert_equal '33.44.55.66', comment.ip_address
    assert_equal 'MyBrowser', comment.user_agent
    assert_equal 'http://example.com', comment.referrer
  end

  should 'invalid comment display the comment form open' do
    article = profile.articles.build(:name => 'test')
    article.save!
    login_as_rails5('testinguser')

    assert_no_difference 'Comment.count' do
      post comment_index_path(profile.identifier), params: {:comment => {:body => ""}, :confirm => 'true', id: article.id}, xhr: true
    end
    assert_match /errorExplanation/, @response.body
  end

  should 'create ApproveComment task when adding a comment in a moderated article' do
    login_as_rails5 @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    commenter = create_user('otheruser').person
    login_as_rails5(commenter.identifier)
    assert_difference 'ApproveComment.count', 1 do
      post comment_index_path(community.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    end
  end

  should 'not create ApproveComment task when the comment author is the same of article author' do
    login_as_rails5 @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = create(Article, :profile => community, :name => 'myarticle', :moderate_comments => true, :author => @profile)
    community.add_moderator(@profile)

    assert_no_difference 'ApproveComment.count' do
      post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    end
  end

  should 'create ApproveComment task with the comment author as requestor' do
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    commenter = create_user('otheruser').person
    login_as_rails5(commenter.identifier)
    assert_difference 'ApproveComment.count', 1 do
      post comment_index_path(community.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    end
    task = Task.last
    assert_equal commenter, task.requestor

  end

  should "create ApproveComment task with the articles's owner profile as the target" do
    login_as_rails5 @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    commenter = create_user('otheruser').person
    login_as_rails5(commenter.identifier)
    assert_difference 'ApproveComment.count', 1 do
      post comment_index_path(community.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    end
    task = Task.last
    assert_equal community, task.target
  end

  should "create ApproveComment task with the comment created_at attribute defined to now" do
    login_as_rails5 @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    now = Time.now
    Time.stubs(:now).returns(now)
    post comment_index_path(community.identifier), params: { :comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    task = Task.last
    assert_equal now.utc.to_s, task.comment.created_at.utc.to_s
  end

  should "render_target be nil in article with moderation" do
    page = profile.articles.create!(:name => 'myarticle', :moderate_comments => true)

    post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...', :name => 'some name', :email => 'some@test.com.br'}, :confirm => 'true', id: page.id}, xhr: true
    assert_nil ActiveSupport::JSON.decode(@response.body)['render_target']
  end

  should "display message 'waitting for approval' of comments in article with moderation" do
    page = profile.articles.create!(:name => 'myarticle', :moderate_comments => true)

    post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...', :name => 'some name', :email => 'some@test.com.br'}, :confirm => 'true', id: page.id}, xhr: true
    assert_match /waiting for approval/, @response.body
  end

  should "render_target be the comment anchor if everithing is fine" do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    assert_match /#{Comment.last.id}/, ActiveSupport::JSON.decode(@response.body)['render_target']
  end

  should "display message 'successfully created' if the comment was saved with success" do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    assert_match /successfully created/, @response.body
  end

  should "render partial comment if everithing is fine" do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...'}, :confirm => 'true', id: page.id}, xhr: true
    assert_match /id="#{Comment.last.anchor}" class="comment-container"/, ActiveSupport::JSON.decode(@response.body)['html']
  end

  should "render the root comment when a reply is made" do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    comment = fast_create(Comment, :body => 'some content', :source_id => page.id, :source_type => 'Article')

    post comment_index_path(profile.identifier), params: {:comment => {:body => 'Some comment...', :reply_of_id => comment.id}, :confirm => 'true', id: page.id}, xhr: true
    assert_match /id="#{comment.anchor}" class="comment-container"/, ActiveSupport::JSON.decode(@response.body)['html']
  end

  should 'filter html content from body' do
    login_as_rails5 @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    post comment_index_path(profile.identifier), params: {:comment => { :title => 'html comment', :body => "this is a <strong id='html_test_comment'>html comment</strong>"}, id: page.id}, xhr: true

    assert Comment.last.body.match(/this is a html comment/)
    !assert_tag :tag => 'strong', :attributes => { :id => 'html_test_comment' }
  end

  should 'filter html content from title' do
    login_as_rails5 @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    post comment_index_path(profile.identifier), params: {:comment => { :title => "html <strong id='html_test_comment'>comment</strong>", :body => "this is a comment"}, id: page.id}, xhr: true
    assert Comment.last.title.match(/html comment/)
    !assert_tag :tag => 'strong', :attributes => { :id => 'html_test_comment' }
  end

  should 'touch article after adding a comment' do
    yesterday = Time.now.yesterday
    Article.record_timestamps = false
    page = create(Article, :profile => profile, :name => 'myarticle', :body => 'the body of the text', :created_at => yesterday, :updated_at => yesterday)
    Article.record_timestamps = true

    login_as_rails5 @profile.identifier
    post comment_index_path(profile.identifier), params: {:comment => {:title => 'crap!', :body => 'I think that this article is crap' }, :confirm => 'true', id: page.id}, xhr: true
    assert_not_equal yesterday, page.reload.updated_at
  end

  should 'follow article when commenting' do
    page = create(Article, :profile => profile, :name => 'myarticle', :body => 'the body of the text')
    login_as_rails5 @profile.identifier

    post comment_index_path(profile.identifier), params: {:comment => {:title => 'crap!', :body => 'I think that this article is crap', :follow_article => true}, :confirm => 'true', id: page.id}, xhr: true
    assert_includes page.person_followers, @profile
  end

  should 'not follow article when commenting' do
    page = create(Article, :profile => profile, :name => 'myarticle', :body => 'the body of the text')
    login_as_rails5 @profile.identifier

    post comment_index_path(profile.identifier), params: {:comment => {:title => 'crap!', :body => 'I think that this article is crap', :follow_article => false }, :confirm => 'true', id: page.id}, xhr: true
    assert_not_includes page.person_followers, @profile
  end

  should 'be able to mark comments as spam' do
    login_as_rails5 profile.identifier
    article = fast_create(Article, :profile_id => profile.id)
    spam = fast_create(Comment, :name => 'foo', :email => 'foo@example.com', :source_id => article.id, :source_type => 'Article')

    post mark_as_spam_comment_path(profile.identifier, spam), xhr: true

    spam.reload
    assert spam.spam?
  end

  should "not be able to mark as spam other people's comments if not moderator or admin" do
    create_user('normaluser')
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'normaluser' # normaluser cannot remove other people's comments
    post mark_as_spam_comment_path(profile.identifier, comment), xhr: true
    comment.reload
    refute comment.spam?
  end

  should "not be able to mark as spam other people's comments if not moderator or admin and return json if is an ajax request" do
    create_user('normaluser')
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'normaluser' # normaluser cannot remove other people's comments

    post mark_as_spam_comment_path(profile.identifier, comment), xhr: true
    assert_response :success
    comment.reload
    refute comment.spam?
    assert_match /\{\"ok\":false\}/, @response.body
  end

  should 'be able to mark as spam  comments on their articles' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')

    login_as_rails5 'testuser' # testuser must be able to remove comments in his articles

    post mark_as_spam_comment_path(profile.identifier, comment), xhr: true
    assert_response :success
    comment.reload
    assert comment.spam?

    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'be able to mark comments as spam if is moderator' do
    commenter = create_user('commenter_user').person
    community = Community.create!(:name => 'Community test', :identifier => 'community-test')
    article = community.articles.create!(:name => 'test', :profile => community)
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')
    community.add_moderator(profile)
    login_as_rails5 profile.identifier

    post mark_as_spam_comment_path(community.identifier, comment), xhr: true
    assert_response :success
    comment.reload
    assert comment.spam?
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'edit comment from a page' do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article', :author_id => profile.id)

    get edit_comment_path(profile.identifier, comment), params: { :comment => { :body => 'Comment edited' }}
    assert_tag :tag => 'textarea', :attributes => { :id => 'comment-field', :title => 'Leave your comment', :placeholder => 'Leave your comment' }, :content =>  /Original comment/
  end

   should 'not crash on edit comment if comment does not exist' do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    get edit_comment_path(profile.identifier, 1000), params: {:comment => { :body => 'Comment edited' }}
    assert_response 404
  end

  should 'not be able to edit comment not logged' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    get edit_comment_path(profile.identifier, comment), params: { :comment => { :body => 'Comment edited' }}
    assert_response 404
  end

  should 'not be able to edit comment if does not have the permission to' do
    user = create_user('any_guy').person
    login_as_rails5 user.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    get edit_comment_path(profile.identifier, comment), params: { :comment => { :body => 'Comment edited' }}
    assert_response 404
  end

  should 'be able to update a comment' do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text', :accept_comments => false)
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article', :author_id => profile)

    post comment_path(profile.identifier, comment), params: {:comment => { :body => 'Comment edited' }}, xhr: true
    assert_equal 'Comment edited', Comment.find(comment.id).body
  end

  should 'not crash on update comment if comment does not exist' do
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    post comment_path(profile.identifier, 1000), params: { :comment => { :body => 'Comment edited' }}
    assert_response 404
  end

  should 'not be able to update comment not logged' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    post comment_path(profile.identifier, comment), params: { :comment => { :body => 'Comment edited' }}, xhr: true
    assert_response 404
  end

  should 'not be able to update comment if does not have the permission to' do
    user = create_user('any_guy').person
    login_as_rails5 user.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    post comment_path(profile.identifier, comment), params: { :comment => { :body => 'Comment edited' }}, xhr: true
    assert_response 404
  end

  should 'returns ids of menu items that has to be displayed' do
    class TestActionPlugin < Noosfero::Plugin
      def check_comment_actions(c)
        ['action1', 'action2']
      end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestActionPlugin.new])
    login_as_rails5 profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')
    post check_actions_comment_path(profile.identifier, comment) 
    assert_match /\{\"ids\":\[\"action1\",\"action2\"\]\}/, @response.body
  end

  should 'send push notification to the article author and followers' do
    commenter = create_user('commenter_user').person
    author = create_user.person
    article = author.articles.create!(name: 'test', profile: author)

    follower1 = create_user.person
    ArticleFollower.create!(article_id: article.id, person_id: follower1.id)
    follower2 = create_user.person
    ArticleFollower.create!(article_id: article.id, person_id: follower2.id)

    [author, follower1, follower2].each do |p|
      p.push_subscriptions.create(endpoint: '/some',
                                  keys: { auth: '123', p256dh: '456' })
    end

    login_as_rails5 commenter.identifier
    post comment_index_path(author.identifier), params: {id: article.id,  comment: { title: 'push', body: 'notification' }}, xhr: true

    Webpush.expects(:payload_send).times(3)
    process_delayed_job_queue
  end
end
