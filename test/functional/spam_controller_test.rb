require_relative "../test_helper"

class SpamControllerTest < ActionController::TestCase

  def setup
    @profile = create_user.person

    @community = fast_create(Community, :name => 'testcommunity')
    @community.add_admin(@profile)
    @article = fast_create(TextileArticle, :profile_id => @community.id)
    @spam_comment = fast_create(Comment, :source_id => @article.id, :spam => true, :name => 'foo', :email => 'foo@example.com')

    @spam_suggest_article = SuggestArticle.create!(:name => 'spammer', :article => {:name => 'Spam article', :body => "Something you don't need"}, :email => 'spammer@shady.place', :target => @community, :spam => true)
    login_as @profile.identifier
  end

  test "should only list spammy comments and spammy suggest articles" do
    ham = fast_create(Comment, :source_id => @article.id)

    get :index, :profile => @community.identifier

    assert_equivalent [@spam_comment], assigns(:comment_spam)
    assert_equivalent [@spam_suggest_article], assigns(:task_spam)
  end

  test "should mark comments as ham" do
    post :index, :profile => @community.identifier, :mark_comment_as_ham => @spam_comment.id

    @spam_comment.reload
    assert @spam_comment.ham?
  end

  test "should mark suggest article as ham" do
    post :index, :profile => @community.identifier, :mark_task_as_ham => @spam_suggest_article.id

    @spam_suggest_article.reload
    assert @spam_suggest_article.ham?
  end

  test "should remove comments" do
    post :index, :profile => @community.identifier, :remove_comment => @spam_comment.id

    assert !Comment.exists?(@spam_comment.id)
  end

  test "should remove suggest articles" do
    post :index, :profile => @community.identifier, :remove_task => @spam_suggest_article.id

    assert !SuggestArticle.exists?(@spam_suggest_article.id)
  end

  should 'properly render spam that have replies' do
    reply_spam = fast_create(Comment, :source_id => @article_id, :reply_of_id => @spam_comment.id)

    get :index, :profile => @community.identifier
    assert_response :success
  end

end
