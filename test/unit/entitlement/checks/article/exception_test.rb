# encoding: UTF-8
require_relative "../../../../test_helper"

class Entitlement::Checks::Article::ExceptionTest < ActiveSupport::TestCase
  def setup
    @article = fast_create(Article)
    @user = create_user('user').person
    @check = Entitlement::Checks::Article::Exception.new(@article)
  end

  attr_reader :article, :user, :check

  should 'not entitle nil user' do
    refute check.entitles?(nil)
  end

  should 'not entitle random user' do
    refute check.entitles?(user)
  end

  should 'entitle exceptional user' do
    article.article_privacy_exceptions << user
    assert check.entitles?(user)
  end
end
