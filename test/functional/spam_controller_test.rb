require File.dirname(__FILE__) + '/../test_helper'

class SpamControllerTest < ActionController::TestCase

  def setup
    @profile = create_user.person
    @article = fast_create(TextileArticle, :profile_id => @profile.id)
    @spam = fast_create(Comment, :source_id => @article.id, :spam => true, :name => 'foo', :email => 'foo@example.com')

    login_as @profile.identifier
  end

  test "should only list spammy comments" do
    ham = fast_create(Comment, :source_id => @article.id)

    get :index, :profile => @profile.identifier

    assert_equivalent [@spam], assigns(:spam)
  end

  test "should mark comments as ham" do
    post :index, :profile => @profile.identifier, :mark_comment_as_ham => @spam.id

    @spam.reload
    assert @spam.ham?
  end

  test "should remove comments" do
    post :index, :profile => @profile.identifier, :remove_comment => @spam.id

    assert !Comment.exists?(@spam.id)
  end


end
