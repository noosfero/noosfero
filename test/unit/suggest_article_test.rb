require File.dirname(__FILE__) + '/../test_helper'

class SuggestArticleTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('test_user').person
  end
  attr_reader :profile

  should 'have the article_name' do
    t = SuggestArticle.new
    assert !t.errors.invalid?(:article_name)
    t.valid?
    assert t.errors.invalid?(:article_name)
  end

  should 'have the article_body' do
    t = SuggestArticle.new
    assert !t.errors.invalid?(:article_body)
    t.valid?
    assert t.errors.invalid?(:article_body)
  end

  should 'have the email' do
    t = SuggestArticle.new
    assert !t.errors.invalid?(:email)
    t.valid?
    assert t.errors.invalid?(:email)
  end

  should 'have the name' do
    t = SuggestArticle.new
    assert !t.errors.invalid?(:name)
    t.valid?
    assert t.errors.invalid?(:name)
  end

  should 'have the target_id' do
    t = SuggestArticle.new
    assert !t.errors.invalid?(:target_id)
    t.valid?
    assert t.errors.invalid?(:target_id)
  end

  should 'have the captcha_solution be solved' do
    t = SuggestArticle.new
    assert !t.errors.invalid?(:captcha_solution)
    t.valid?
    assert t.errors.invalid?(:captcha_solution)

    t.skip_captcha!
    assert t.skip_captcha?
    t.valid?
    assert !t.errors.invalid?(:captcha_solution)
  end

  should 'have the article_abstract' do
    t = SuggestArticle.new
    assert t.respond_to?(:article_abstract)
  end

  should 'have the article_parent_id' do
    t = SuggestArticle.new
    assert t.respond_to?(:article_parent_id)
  end

  should 'source be defined' do
    t = SuggestArticle.new
    assert t.respond_to?(:source)
  end

  should 'create an article on with perfom method' do
    t = SuggestArticle.new
    name = 'some name'
    body = 'some body'
    abstract = 'some abstract'
    t.article_name = name
    t.article_body = body
    t.article_abstract = abstract
    t.target = @profile
    count = TinyMceArticle.count
    t.perform
    assert_equal count + 1, TinyMceArticle.count
  end

end
