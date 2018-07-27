# encoding: UTF-8
require_relative "../../test_helper"

class Entitlement::ArticleJudgeTest < ActiveSupport::TestCase
  def setup
    @article = fast_create(Article)
  end

  attr_reader :article

  should 'define access requirement as max between content access and profile requirement' do
    article.stubs(:profile_requirement).returns(15)
    article.stubs(:access).returns(10)
    assert_equal 15, article.access_requirement

    article.stubs(:profile_requirement).returns(15)
    article.stubs(:access).returns(20)
    assert_equal 20, article.access_requirement
  end
end
