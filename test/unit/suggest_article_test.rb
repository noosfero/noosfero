require_relative "../test_helper"

class SuggestArticleTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('test_user').person
    Noosfero::Plugin.stubs(:all).returns(['SuggestArticleTest::EverythingIsSpam', 'SuggestArticleTest::SpamNotification'])
  end
  attr_reader :profile

  should 'have the article_name' do
    t = SuggestArticle.new
    assert !t.article_object.errors[:name].present?
    t.article_object.valid?
    assert t.article_object.errors[:name].present?
  end

  should 'have the email' do
    t = SuggestArticle.new
    assert !t.errors[:email.to_s].present?
    t.valid?
    assert t.errors[:email.to_s].present?
  end

  should 'have the name' do
    t = SuggestArticle.new
    assert !t.errors[:name.to_s].present?
    t.valid?
    assert t.errors[:name.to_s].present?
  end

  should 'have the target_id' do
    t = SuggestArticle.new
    assert !t.errors[:target_id.to_s].present?
    t.valid?
    assert t.errors[:target_id.to_s].present?
  end

  should 'have the article' do
    t = SuggestArticle.new
    assert t.respond_to?(:article_object)
    assert !t.errors[:article_object].present?
    t.valid?
    assert t.errors[:article_object].present?
  end

  should 'create an article on with perfom method' do
    t = SuggestArticle.new
    name = 'some name'
    body = 'some body'
    abstract = 'some abstract'
    t.article = {:name => name, :body => body, :abstract => abstract}
    t.target = @profile
    count = TinyMceArticle.count
    t.perform
    assert_equal count + 1, TinyMceArticle.count
  end

  should 'fill source name and URL into created article' do
    t = build(SuggestArticle, :target => @profile)
    t.article.merge!({:source_name => 'GNU project', :source => 'http://www.gnu.org/'})
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
    t.article[:highlighted] = true
    t.perform

    article = TinyMceArticle.last(:conditions => { :name => t.article_name}) # just to be sure
    assert article.highlighted
  end

  should 'not be highlighted by default' do
    t = build(SuggestArticle, :target => @profile)
    t.perform

    article = TinyMceArticle.last(:conditions => { :name => t.article_name})
    assert_equal false, article.highlighted
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
    task = build(SuggestArticle, :target => @profile, :article => {:name => 'suggested article'}, :name => 'johndoe')

    assert_match(/#{task.name}.*suggested the publication of the article: #{task.subject}.*[\n]*.*to approve or reject/, task.target_notification_message)
  end

  should 'have target notification description' do
    task = build(SuggestArticle,:target => @profile, :article => {:name => 'suggested article'}, :name => 'johndoe')

    assert_match(/#{task.name}.*suggested the publication of the article: #{task.subject}/, task.target_notification_description)
  end

  should 'deliver target notification message' do
    task = build(SuggestArticle, :target => @profile, :article => {:name => 'suggested article'}, :name => 'johndoe', :email => 'johndoe@example.com')

    email = TaskMailer.target_notification(task, task.target_notification_message).deliver

    assert_match(/#{task.name}.*suggested the publication of the article: #{task.subject}/, email.subject)
  end

  class EverythingIsSpam < Noosfero::Plugin
    def check_for_spam(object)
      object.spam!
    end
  end

  should 'delegate spam detection to plugins' do
    Environment.default.enable_plugin(EverythingIsSpam)

    t1 = build(SuggestArticle, :target => @profile, :article => {:name => 'suggested article'}, :name => 'johndoe', :email => 'johndoe@example.com')

    EverythingIsSpam.any_instance.expects(:check_for_spam)

    t1.check_for_spam
  end

  class SpamNotification < Noosfero::Plugin
    class << self
      attr_accessor :marked_as_spam
      attr_accessor :marked_as_ham
    end

    def check_for_spam(c)
      # do nothing
    end

    def marked_as_spam(c)
      self.class.marked_as_spam = c
    end

    def marked_as_ham(c)
      self.class.marked_as_ham = c
    end
  end

  should 'notify plugins of suggest_articles being marked as spam' do
    Environment.default.enable_plugin(SpamNotification)

    t = SuggestArticle.create!(:target => @profile, :article => {:name => 'suggested article', :body => 'wanna feel my body? my body baaaby'}, :name => 'johndoe', :email => 'johndoe@example.com')

    t.spam!
    process_delayed_job_queue

    assert_equal t, SpamNotification.marked_as_spam
  end

  should 'notify plugins of suggest_articles being marked as ham' do
    Environment.default.enable_plugin(SpamNotification)

    t = SuggestArticle.create!(:target => @profile, :article => {:name => 'suggested article', :body => 'wanna feel my body? my body baaaby'}, :name => 'johndoe', :email => 'johndoe@example.com')

    t.ham!
    process_delayed_job_queue

    assert_equal t, SpamNotification.marked_as_ham
  end

  should 'store User-Agent' do
    t = SuggestArticle.new(:user_agent => 'foo')
    assert_equal 'foo', t.user_agent
  end

  should 'store referrer' do
    t = SuggestArticle.new(:referrer => 'bar')
    assert_equal 'bar', t.referrer
  end

  should 'log spammer ip after marking comment as spam' do
    t = SuggestArticle.create!(:target => @profile, :article => {:name => 'suggested article', :body => 'wanna feel my body? my body baaaby'}, :name => 'johndoe', :email => 'johndoe@example.com', :ip_address => '192.168.0.1')
    t.spam!
    log = File.open('log/test_spammers.log')
    assert_match "SuggestArticle-id: #{t.id} IP: 192.168.0.1", log.read
  end

  should 'not require name and email when requestor is present' do
    t = SuggestArticle.new(:requestor => fast_create(Person))
    t.valid?
    assert t.errors[:email].blank?
    assert t.errors[:name].blank?
  end

  should 'return name as sender when requestor is setted' do
    person = fast_create(Person)
    t = SuggestArticle.new(:requestor => person)
    assert_equal person.name, t.sender
  end

  should 'create an event on perfom method' do
    t = SuggestArticle.new
    t.article = {:name => 'name', :body => 'body', :type => 'Event'}
    t.target = @profile
    assert_difference "Event.count" do
      t.perform
    end
  end

  should 'accept article type parameter' do
    t = SuggestArticle.new
    t.article = {:name => 'name', :body => 'body', :type => 'TextArticle'}
    t.article_type == TextArticle
  end

  should 'fallback to tinymce when type parameter is invalid' do
    t = SuggestArticle.new
    t.article = {:name => 'name', :body => 'body', :type => 'Comment'}
    t.article_type == TinyMceArticle
  end

end
