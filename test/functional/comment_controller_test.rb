require_relative "../test_helper"
require 'comment_controller'

class CommentControllerTest < ActionController::TestCase

  def setup
    @controller = CommentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

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

    login_as 'normaluser' # normaluser cannot remove other people's comments
    assert_no_difference 'Comment.count' do
      post :destroy, :profile => profile.identifier, :id => comment.id
    end
  end

  should "not be able to remove other people's comments if not moderator or admin and return json if is an ajax request" do
    create_user('normaluser')
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!

    commenter = create_user('otheruser').person
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')

    login_as 'normaluser' # normaluser cannot remove other people's comments
    assert_no_difference 'Comment.count' do
      xhr :post, :destroy, :profile => profile.identifier, :id => comment.id
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

    login_as 'testuser' # testuser must be able to remove comments in his articles
    assert_difference 'Comment.count', -1 do
      xhr :post, :destroy, :profile => profile.identifier, :id => comment.id
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

    login_as 'testuser' # testuser must be able to remove comments in his articles
    assert_difference 'Comment.count', -1 do
      xhr :post, :destroy, :profile => profile.identifier, :id => comment.id
      assert_response :success
    end
  end

  should 'be able to remove comments if is moderator' do
    commenter = create_user('commenter_user').person
    community = Community.create!(:name => 'Community test', :identifier => 'community-test')
    article = community.articles.create!(:name => 'test', :profile => community)
    comment = fast_create(Comment, :source_id => article, :author_id => commenter, :title => 'a comment', :body => 'lalala')
    community.add_moderator(profile)
    login_as profile.identifier
    assert_difference 'Comment.count', -1 do
      xhr :post, :destroy, :profile => community.identifier, :id => comment.id
      assert_response :success
    end
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'be able to remove comment' do
    profile = create_user('testuser').person
    article = profile.articles.build(:name => 'test')
    article.save!
    comment = fast_create(Comment, :source_id => article, :author_id => profile, :title => 'a comment', :body => 'lalala')

    login_as 'testuser'
    assert_difference 'Comment.count', -1 do
      xhr :post, :destroy, :profile => profile.identifier, :id => comment.id
      assert_response :success
    end
  end

  should 'display not found page if a user should try to make a cross comment' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    other_person = create_user('otheruser').person
    other_page = other_person.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    assert_no_difference 'Comment.count' do
      xhr :post, :create, :profile => profile.identifier, :id => other_page.id, :comment => { :title => 'crap!', :body => 'I think that this article is crap' }
    end
     assert_match /not found/, @response.body
  end

  should 'not be able to post comment if article do not accept it' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text', :accept_comments => false)

    assert_no_difference 'Comment.count' do
      xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'crap!', :body => 'I think that this article is crap' }
    end
     assert_match /Comment not allowed in this article/, @response.body
  end

  should "the author's comment be the logged user" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    login_as profile.identifier

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'crap!', :body => 'I think that this article is crap' }
    assert_equal profile, assigns(:comment).author
  end

  should "the articles's comment be the article passed as parameter" do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    login_as profile.identifier

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'crap!', :body => 'I think that this article is crap' }
    assert_equal page, assigns(:comment).article
  end

  should 'show validation error when body comment is missing' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    xhr :post, :create, :profile => @profile.identifier, :id => page.id, :comment => { :title => '', :body => '' }, :confirm => 'true'
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
      xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'title', :body => 'body', :name => "Spammer", :email => 'damn@spammer.com' }, :confirm => 'true'
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
      xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'title', :body => 'body', :name => "Spammer", :email => 'damn@spammer.com' }, :confirm => 'true'
    end

    assert_match /rejected/, @response.body
  end

  should 'store IP address, user agent and referrer for comments' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    @request.stubs(:remote_ip).returns('33.44.55.66')
    @request.stubs(:referrer).returns('http://example.com')
    @request.stubs(:user_agent).returns('MyBrowser')
    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'title', :body => 'body', :name => "Spammer", :email => 'damn@spammer.com' }, :confirm => 'true'
    comment = Comment.last
    assert_equal '33.44.55.66', comment.ip_address
    assert_equal 'MyBrowser', comment.user_agent
    assert_equal 'http://example.com', comment.referrer
  end

  should 'invalid comment display the comment form open' do
    article = profile.articles.build(:name => 'test')
    article.save!
    login_as('testinguser')

    assert_no_difference 'Comment.count' do
      xhr :post, :create, :profile => profile.identifier, :id =>article.id, :comment => {:body => ""}, :confirm => 'true'
    end
    assert_match /post_comment_box opened/, @response.body
  end

  should 'invalid captcha display the comment form open' do
    article = profile.articles.build(:name => 'test')
    article.save!
    login_as('testinguser')
    @controller.stubs(:verify_recaptcha).returns(false)

    environment.enable('captcha_for_logged_users')
    environment.save!

    xhr :post, :create, :profile => profile.identifier, :id =>article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    assert_match /post_comment_box opened/, @response.body
  end

  should 'ask for captcha if environment defines even with logged user' do
    article = profile.articles.build(:name => 'test')
    article.save!
    login_as('testinguser')
    @controller.stubs(:verify_recaptcha).returns(false)

    assert_difference 'Comment.count', 1 do
      xhr :post, :create, :profile => profile.identifier, :id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    end

    environment.enable('captcha_for_logged_users')
    environment.save!

    assert_no_difference 'Comment.count' do
      xhr :post, :create, :profile => profile.identifier, :id =>article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    end
    assert_not_nil assigns(:comment)
  end

  should 'ask for captcha if user not logged' do
    article = profile.articles.build(:name => 'test')
    article.save!

    @controller.stubs(:verify_recaptcha).returns(false)
    logout
    assert_no_difference 'Comment.count' do
      xhr :post, :create, :profile => profile.identifier, :id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    end

    @controller.stubs(:verify_recaptcha).returns(true)
    login_as profile.identifier
    assert_difference 'Comment.count', 1 do
      xhr :post, :create, :profile => profile.identifier, :id => article.id, :comment => {:body => "Some comment..."}, :confirm => 'true'
    end
  end

  should 'create ApproveComment task when adding a comment in a moderated article' do
    login_as @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    commenter = create_user('otheruser').person
    login_as(commenter.identifier)
    assert_difference 'ApproveComment.count', 1 do
      xhr :post, :create, :profile => community.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    end
  end

  should 'not create ApproveComment task when the comment author is the same of article author' do
    login_as @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = create(Article, :profile => community, :name => 'myarticle', :moderate_comments => true, :author => @profile)
    community.add_moderator(@profile)

    assert_no_difference 'ApproveComment.count' do
      xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    end
  end

  should 'create ApproveComment task with the comment author as requestor' do
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    commenter = create_user('otheruser').person
    login_as(commenter.identifier)
    assert_difference 'ApproveComment.count', 1 do
      xhr :post, :create, :profile => community.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    end
    task = Task.last
    assert_equal commenter, task.requestor

  end

  should "create ApproveComment task with the articles's owner profile as the target" do
    login_as @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    commenter = create_user('otheruser').person
    login_as(commenter.identifier)
    assert_difference 'ApproveComment.count', 1 do
      xhr :post, :create, :profile => community.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    end
    task = Task.last
    assert_equal community, task.target
  end

  should "create ApproveComment task with the comment created_at attribute defined to now" do
    login_as @profile.identifier
    community = Community.create!(:name => 'testcomm')
    page = community.articles.create!(:name => 'myarticle', :moderate_comments => true)

    now = Time.now
    Time.stubs(:now).returns(now)
    xhr :post, :create, :profile => community.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    task = Task.last
    assert_equal now.utc.to_s, task.comment.created_at.utc.to_s
  end

  should "render_target be nil in article with moderation" do
    page = profile.articles.create!(:name => 'myarticle', :moderate_comments => true)

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...', :name => 'some name', :email => 'some@test.com.br'}, :confirm => 'true'
    assert_nil ActiveSupport::JSON.decode(@response.body)['render_target']
  end

  should "display message 'waitting for approval' of comments in article with moderation" do
    page = profile.articles.create!(:name => 'myarticle', :moderate_comments => true)

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...', :name => 'some name', :email => 'some@test.com.br'}, :confirm => 'true'
    assert_match /waiting for approval/, @response.body
  end

  should "render_target be the comment anchor if everithing is fine" do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    assert_match /#{Comment.last.id}/, ActiveSupport::JSON.decode(@response.body)['render_target']
  end

  should "display message 'successfully created' if the comment was saved with success" do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    assert_match /successfully created/, @response.body
  end

  should "render partial comment if everithing is fine" do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...'}, :confirm => 'true'
    assert_match /id="#{Comment.last.anchor}" class="article-comment"/, ActiveSupport::JSON.decode(@response.body)['html']
  end

  should "render the root comment when a reply is made" do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle')

    comment = fast_create(Comment, :body => 'some content', :source_id => page.id, :source_type => 'Article')

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:body => 'Some comment...', :reply_of_id => comment.id}, :confirm => 'true'
    assert_match /id="#{comment.anchor}" class="article-comment"/, ActiveSupport::JSON.decode(@response.body)['html']
  end

  should 'filter html content from body' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => 'html comment', :body => "this is a <strong id='html_test_comment'>html comment</strong>"}

    assert Comment.last.body.match(/this is a html comment/)
    assert_no_tag :tag => 'strong', :attributes => { :id => 'html_test_comment' }
  end

  should 'filter html content from title' do
    login_as @profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => { :title => "html <strong id='html_test_comment'>comment</strong>", :body => "this is a comment"}
    assert Comment.last.title.match(/html comment/)
    assert_no_tag :tag => 'strong', :attributes => { :id => 'html_test_comment' }
  end

  should 'touch article after adding a comment' do
    yesterday = Time.now.yesterday
    Article.record_timestamps = false
    page = create(Article, :profile => profile, :name => 'myarticle', :body => 'the body of the text', :created_at => yesterday, :updated_at => yesterday)
    Article.record_timestamps = true

    login_as @profile.identifier
    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:title => 'crap!', :body => 'I think that this article is crap' }, :confirm => 'true'
    assert_not_equal yesterday, page.reload.updated_at
  end

  should 'follow article when commenting' do
    page = create(Article, :profile => profile, :name => 'myarticle', :body => 'the body of the text')
    login_as @profile.identifier

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:title => 'crap!', :body => 'I think that this article is crap', :follow_article => true}, :confirm => 'true'
    assert_includes page.person_followers, @profile
  end

  should 'not follow article when commenting' do
    page = create(Article, :profile => profile, :name => 'myarticle', :body => 'the body of the text')
    login_as @profile.identifier

    xhr :post, :create, :profile => profile.identifier, :id => page.id, :comment => {:title => 'crap!', :body => 'I think that this article is crap', :follow_article => false }, :confirm => 'true'
    assert_not_includes page.person_followers, @profile
  end

  should 'be able to mark comments as spam' do
    login_as profile.identifier
    article = fast_create(Article, :profile_id => profile.id)
    spam = fast_create(Comment, :name => 'foo', :email => 'foo@example.com', :source_id => article.id, :source_type => 'Article')

    xhr :post, :mark_as_spam, :profile => profile.identifier, :id => spam.id

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

    login_as 'normaluser' # normaluser cannot remove other people's comments
    xhr :post, :mark_as_spam, :profile => profile.identifier, :id => comment.id
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

    login_as 'normaluser' # normaluser cannot remove other people's comments

    xhr :post, :mark_as_spam, :profile => profile.identifier, :id => comment.id
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

    login_as 'testuser' # testuser must be able to remove comments in his articles

    xhr :post, :mark_as_spam, :profile => profile.identifier, :id => comment.id
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
    login_as profile.identifier

    xhr :post, :mark_as_spam, :profile => community.identifier, :id => comment.id
    assert_response :success
    comment.reload
    assert comment.spam?
    assert_match /\{\"ok\":true\}/, @response.body
  end

  should 'edit comment from a page' do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article', :author_id => profile.id)

    get :edit, :id => comment.id, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_tag :tag => 'textarea', :attributes => {:id => 'comment_body'}, :content => /Original comment/
  end

   should 'not crash on edit comment if comment does not exist' do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    get :edit, :id => 1000, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_response 404
  end

  should 'not be able to edit comment not logged' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    get :edit, :id => comment.id, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_response 404
  end

  should 'not be able to edit comment if does not have the permission to' do
    user = create_user('any_guy').person
    login_as user.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    get :edit, :id => comment.id, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_response 404
  end

  should 'be able to update a comment' do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text', :accept_comments => false)
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article', :author_id => profile)

    xhr :post, :update, :id => comment.id, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert ActiveSupport::JSON.decode(@response.body)["ok"], "attribute ok expected to be true"
    assert_equal 'Comment edited', Comment.find(comment.id).body
  end

  should 'not crash on update comment if comment does not exist' do
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')

    xhr :post, :update, :id => 1000, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_response 404
  end

  should 'not be able to update comment not logged' do
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    xhr :post, :update, :id => comment.id, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_response 404
  end

  should 'not be able to update comment if does not have the permission to' do
    user = create_user('any_guy').person
    login_as user.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')

    xhr :post, :update, :id => comment.id, :profile => profile.identifier, :comment => { :body => 'Comment edited' }
    assert_response 404
  end

  should 'returns ids of menu items that has to be displayed' do
    class TestActionPlugin < Noosfero::Plugin
      def check_comment_actions(c)
        ['action1', 'action2']
      end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([TestActionPlugin.new])
    login_as profile.identifier
    page = profile.articles.create!(:name => 'myarticle', :body => 'the body of the text')
    comment = fast_create(Comment, :body => 'Original comment', :source_id => page.id, :source_type => 'Article')
    xhr :post, :check_actions, :profile => profile.identifier, :id => comment.id
    assert_match /\{\"ids\":\[\"action1\",\"action2\"\]\}/, @response.body
  end

end
