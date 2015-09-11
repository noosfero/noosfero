require_relative "../test_helper"

class ApproveArticleTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    User.current = @user = create_user 'test_user'
    @profile = @user.person
    @article = fast_create(TextileArticle, :profile_id => @profile.id, :name => 'test name', :abstract => 'Lead of article', :body => 'This is my article')
    @community = fast_create(Community)
    @community.add_member(@profile)
  end
  attr_reader :profile, :article, :community

  should 'have name, reference article and profile' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)

    assert_equal article, a.article
    assert_equal community, a.target
  end

  should 'have abstract and body' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)

    assert_equal ['Lead of article', 'This is my article'], [a.abstract, a.body]
  end

  should 'create an article with the same class as original when finished' do
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)

    assert_difference 'article.class.count' do
      a.finish
    end
  end

  should 'override target notification message method from Task' do
    p1 = profile
    p2 = create_user('testuser2').person
    task = build(AddFriend, :person => p1, :friend => p2)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'have parent if defined' do
    folder = create(Folder, :name => 'test folder', :profile => profile)

    a = create(ApproveArticle, :name => 'test name', :article => article, :target => profile, :requestor => profile, :article_parent_id => folder.id)

    assert_equal folder, a.article_parent
  end

  should 'not have parent if not defined' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_nil a.article_parent
  end

  should 'alert when reference article is removed' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => profile, :requestor => profile)

    article.destroy
    a.reload

    assert_equal "The article was removed.", a.information[:message]
  end

  should 'preserve article_parent' do
    a = build(ApproveArticle, :article_parent => article)

    assert_equal article, a.article_parent
  end

  should 'handle blank names' do
    a = create(ApproveArticle, :name => '', :article => article, :target => community, :requestor => profile)

    assert_difference 'article.class.count' do
      a.finish
    end
  end

  should 'notify target if group is moderated' do
    community.moderated_articles = true
    community.save
    community.stubs(:notification_emails).returns(['adm@example.com'])

    a = create(ApproveArticle, :name => '', :article => article, :target => community, :requestor => profile)
    refute ActionMailer::Base.deliveries.empty?
  end

  should 'not notify target if group is not moderated' do
    community.moderated_articles = false
    community.save

    a = create(ApproveArticle, :name => '', :article => article, :target => community, :requestor => profile)
    assert ActionMailer::Base.deliveries.empty?
  end

  should 'copy the source from the original article' do
    article.source = 'sample-feed.com'
    article.save

    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal article.class.last.source, article.source
  end

  should 'have a reference article and profile on published article' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    published = article.class.last
    assert_equal [article, community], [published.reference_article, published.profile]
  end

  should 'copy name from original article' do
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 'test name', article.class.last.name
  end

  should 'be able to edit name of generated article' do
    a = create(ApproveArticle, :name => 'Other name', :article => article, :target => community, :requestor => profile)
    a.abstract = 'Abstract edited';a.save
    a.finish

    assert_equal 'Other name', article.class.last.name
  end

  should 'copy abstract from original article' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 'Lead of article', article.class.last.abstract
  end

  should 'be able to edit abstract of generated article' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.abstract = 'Abstract edited';a.save
    a.finish

    assert_equal 'Abstract edited', article.class.last.abstract
  end

  should 'copy body from original article' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 'This is my article', article.class.last.body
  end

  should 'be able to edit body of generated article' do
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.body = 'Body edited';a.save
    a.finish

    assert_equal 'Body edited', article.class.last.body
  end

  should 'not be created in blog if community does not have a blog' do
    profile_blog = fast_create(Blog, :profile_id => profile.id)
    article.parent = profile_blog
    article.save

    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    refute community.has_blog?
    assert_nil article.class.last.parent
  end

  should 'be created in community blog if came from a blog' do
    profile_blog = fast_create(Blog, :profile_id => profile.id)
    article.parent = profile_blog
    article.save

    community.articles << Blog.new(:profile => community)
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal community.blog, article.class.last.parent
  end

  should 'not be created in community blog if did not come from a blog' do
    profile_folder = fast_create(Folder, :profile_id => profile.id)
    article.parent = profile_folder
    article.save

    blog = fast_create(Blog, :profile_id => community.id)
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    assert_nil article.class.last.parent
  end

  should 'overwrite blog if parent was choosen on published' do
    profile_blog = fast_create(Blog, :profile_id => profile.id)
    article.parent = profile_blog
    article.save

    community.articles << Blog.new(:profile => community)
    community_folder = fast_create(Folder, :profile_id => profile.id)

    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile, :article_parent => community_folder)
    a.finish

    assert_equal community_folder, article.class.last.parent
  end

  should 'use author from original article on published' do
    article.class.any_instance.stubs(:author).returns(profile)
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal profile, article.class.last.author
  end

  should 'use original article author even if article is destroyed' do
    article.class.any_instance.stubs(:author).returns(profile)
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    article.destroy

    assert_equal profile, article.class.last.author
  end

  should 'the published article have parent if defined' do
    folder = fast_create(Folder, :profile_id => community.id)
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile, :article_parent => folder)
    a.finish

    assert_equal folder, article.class.last.parent
  end

  should 'copy to_html from reference_article' do
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal article.to_html, article.class.last.to_html
  end

  should 'notify activity on creating published' do
    ActionTracker::Record.delete_all
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 1, ActionTracker::Record.count
  end

  should 'not group trackers activity of article\'s creation' do
    other_community = fast_create(Community)
    other_community.add_member(profile)
    ActionTracker::Record.delete_all

    article = fast_create(TextileArticle)
    a = create(ApproveArticle, :name => 'bar', :article => article, :target => community, :requestor => profile)
    a.finish

    article = fast_create(TextileArticle)
    a = create(ApproveArticle, :name => 'another bar', :article => article, :target => community, :requestor => profile)
    a.finish

    article = fast_create(TextileArticle)
    a = create(ApproveArticle, :name => 'another bar', :article => article, :target => other_community, :requestor => profile)
    a.finish
    assert_equal 3, ActionTracker::Record.count
  end

  should 'not create trackers activity when updating articles' do
    other_community = fast_create(Community)
    other_community.add_member(profile)
    ActionTracker::Record.delete_all
    article1 = fast_create(TextileArticle)
    a = create(ApproveArticle, :name => 'bar', :article => article1, :target => community, :requestor => profile)
    a.finish

    article2 = fast_create(TinyMceArticle)
    a = create(ApproveArticle, :name => 'another bar', :article => article2, :target => other_community, :requestor => profile)
    a.finish
    assert_equal 2, ActionTracker::Record.count

    assert_no_difference 'ActionTracker::Record.count' do
      published = article1.class.last
      published.name = 'foo';published.save!

      published = article2.class.last
      published.name = 'another foo';published.save!
    end
  end

  should "the tracker action target be defined as the article on articles'creation in communities" do
    ActionTracker::Record.delete_all
    person = fast_create(Person)
    community.add_member(person)

    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    approved_article = community.articles.find_by_name(article.name)

    assert_equal approved_article, ActionTracker::Record.last.target
  end

  should "the tracker action target be defined as the article on articles'creation in profile" do
    ActionTracker::Record.delete_all
    person = fast_create(Person)
    person.stubs(:notification_emails).returns(['target@example.org'])

    a = create(ApproveArticle, :article => article, :target => person, :requestor => person)
    a.finish

    approved_article = person.articles.find_by_name(article.name)

    assert_equal approved_article, ActionTracker::Record.last.target
  end

  should "have the same is_trackable method as original article" do
    a = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal article.is_trackable?, article.class.last.is_trackable?
  end

  should 'not have target notification message if it is not a moderated oganization' do
    community.moderated_articles = false; community.save
    task = build(ApproveArticle, :article => article, :target => community, :requestor => profile)

    assert_nil task.target_notification_message
  end

  should 'have target notification message if is organization and not moderated' do
    task = build(ApproveArticle, :article => article, :target => community, :requestor => profile)

    community.expects(:moderated_articles?).returns(['true'])

    assert_match(/wants to publish the article.*[\n]*.*to approve or reject/, task.target_notification_message)
  end

  should 'have target notification description' do
    community.moderated_articles = false; community.save
    task = build(ApproveArticle, :article => article, :target => community, :requestor => profile)

    assert_match(/#{task.requestor.name} wants to publish the article: #{article.name}/, task.target_notification_description)
  end

  should 'deliver target notification message' do
    task = build(ApproveArticle, :article => article, :target => community, :requestor => profile)

    community.expects(:notification_emails).returns(['target@example.com'])
    community.expects(:moderated_articles?).returns(['true'])

    email = TaskMailer.target_notification(task, task.target_notification_message).deliver
    assert_match(/#{task.requestor.name} wants to publish the article: #{article.name}/, email.subject)
  end

  should 'deliver target finished message' do
    task = build(ApproveArticle, :article => article, :target => community, :requestor => profile)

    email = task.send(:send_notification, :finished).deliver

    assert_match(/#{task.requestor.name} wants to publish the article: #{article.name}/, email.subject)
  end

  should 'deliver target finished message about article deleted' do
    task = build(ApproveArticle, :article => article, :target => community, :requestor => profile)
    article.destroy

    email = task.send(:send_notification, :finished).deliver

    assert_match(/#{task.requestor.name} wanted to publish an article but it was removed/, email.subject)
  end

  should 'approve an event' do
    event = fast_create(Event, :profile_id => profile.id, :name => 'Event test', :slug => 'event-test', :abstract => 'Lead of article', :body => 'This is my event')
    task = create(ApproveArticle, :name => 'Event test', :article => event, :target => community, :requestor => profile)
    assert_difference 'event.class.count' do
      task.finish
    end
  end

  should 'approve same article twice changing its name' do
    task1 = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    assert_difference 'article.class.count' do
      task1.finish
    end
    task2 = create(ApproveArticle, :name => article.name + ' v2', :article => article, :target => community, :requestor => profile)
    assert_difference 'article.class.count' do
      assert_nothing_raised ActiveRecord::RecordInvalid do
         task2.finish
      end
    end
  end

  should 'not approve same article twice if not changing its name' do
    task1 = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    assert_difference 'article.class.count' do
      task1.finish
    end
    task2 = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    assert_no_difference 'article.class.count' do
      assert_raises ActiveRecord::RecordInvalid do
         task2.finish
      end
    end
  end

  should 'return reject message even without reject explanation' do
    task = build(ApproveArticle, :name => 'My Article')
    assert_not_nil task.task_cancelled_message
  end

  should 'show the name of the article in the reject message' do
    task = build(ApproveArticle, :name => 'My Article')
    assert_match /My Article/, task.task_cancelled_message
  end

  should 'not save 4 on the new article\'s last_changed_by_ud after approval if author is nil' do
    article = fast_create(Article)
    task = create(ApproveArticle, :article => article, :target => community, :requestor => profile)
    task.finish
    new_article = Article.last
    assert_nil new_article.last_changed_by_id
  end

  should 'not crash if target has its own domain' do
    article = fast_create(Article)
    profile.domains << create(Domain, :name => 'example.org')
    assert_nothing_raised do
      create(ApproveArticle, :article => article, :target => profile, :requestor => profile)
    end
  end

  should 'create link to referenced article' do
    article = fast_create(Article)
    a = create(ApproveArticle, :name => 'test name', :article => article, :target => community, :requestor => profile)
    a.create_link = true
    a.finish

    assert_equal article, LinkArticle.last.reference_article
  end

  should 'not allow non-person requestor' do
    task = ApproveArticle.new(:requestor => Community.new)
    task.valid?
    assert task.invalid?(:requestor)
  end

  should 'allow only self requestors when the target is a person' do
    person = fast_create(Person)
    another_person = fast_create(Person)

    t1 = ApproveArticle.new(:requestor => person, :target => person)
    t2 = ApproveArticle.new(:requestor => another_person, :target => person)

    assert t1.valid?
    assert !t2.valid?
    assert t2.invalid?(:requestor)
  end

  should 'allow only members to be requestors when target is a community' do
    community = fast_create(Community)
    member = fast_create(Person)
    community.add_member(member)
    non_member = fast_create(Person)

    t1 = ApproveArticle.new(:requestor => member, :target => community)
    t2 = ApproveArticle.new(:requestor => non_member, :target => community)

    assert t1.valid?
    assert !t2.valid?
    assert t2.invalid?(:requestor)
  end

  should 'allow any user to be requestor whe the target is the portal community' do
    community = fast_create(Community)
    environment = community.environment
    environment.portal_community = community
    environment.save!
    person = fast_create(Person)

    task = ApproveArticle.new(:requestor => person, :target => community)

    assert task.valid?
  end
end
