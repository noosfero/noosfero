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

  should 'fill source name and URL into created article' do
    t = build(SuggestArticle, :target => @profile)
    t.source_name = 'GNU project'
    t.source = 'http://www.gnu.org/'
    t.perform

    article = TinyMceArticle.last
    assert_equal 'GNU project', article.source_name
    assert_equal 'http://www.gnu.org/', article.source
  end

  should 'use name and e-mail as sender info' do
    t = build(SuggestArticle, :target => @profile)
    t.name = 'Some One'
    t.email = 'someone@example.com'
    assert_match(/.*Some One.*someone@example.com/, t.sender)
  end

  should 'highlight created article' do
    t = build(SuggestArticle, :target => @profile)
    t.highlighted = true
    t.perform

    article = TinyMceArticle.last(:conditions => { :name => t.article_name}) # just to be sure
    assert article.highlighted
  end

  should 'override target notification message method from Task' do
    task = build(SuggestArticle, :target => @profile)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'notify community moderators after create article suggestions' do
    task = build(SuggestArticle, :target => @profile)
    task.save
  end

  should 'fill name into author_name created article' do
    t = build(SuggestArticle, :target => @profile)
    t.name = 'some name'
    t.perform

    article = TinyMceArticle.last
    assert_equal 'some name', article.author_name
  end

  should 'have target notification message' do
    task = build(SuggestArticle, :target => @profile, :article_name => 'suggested article', :name => 'johndoe')

    assert_match(/#{task.name}.*suggested the publication of the article: #{task.subject}.*[\n]*.*to approve or reject/, task.target_notification_message)
  end

  should 'have target notification description' do
    task = build(SuggestArticle,:target => @profile, :article_name => 'suggested article', :name => 'johndoe')

    assert_match(/#{task.name}.*suggested the publication of the article: #{task.subject}/, task.target_notification_description)
  end

  should 'deliver target notification message' do
    task = build(SuggestArticle, :target => @profile, :article_name => 'suggested article', :name => 'johndoe', :email => 'johndoe@example.com')

    email = TaskMailer.deliver_target_notification(task, task.target_notification_message)

    assert_match(/#{task.name}.*suggested the publication of the article: #{task.subject}/, email.subject)
  end


end
