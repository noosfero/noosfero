require File.dirname(__FILE__) + '/../test_helper'

class ApproveArticleTest < ActiveSupport::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @profile = create_user('test_user').person
    @article = fast_create(TextileArticle, :profile_id => @profile.id, :name => 'test name', :abstract => 'Lead of article', :body => 'This is my article')
    @community = fast_create(Community)
  end
  attr_reader :profile, :article, :community

  should 'have name, reference article and profile' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)

    assert_equal article, a.article
    assert_equal community, a.target
  end

  should 'have abstract and body' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)

    assert_equal ['Lead of article', 'This is my article'], [a.abstract, a.body]
  end

  should 'create an article with the same class as original when finished' do
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)

    assert_difference article.class, :count do
      a.finish
    end
  end

  should 'override target notification message method from Task' do
    p1 = profile
    p2 = create_user('testuser2').person
    task = AddFriend.new(:person => p1, :friend => p2)
    assert_nothing_raised NotImplementedError do
      task.target_notification_message
    end
  end

  should 'have parent if defined' do
    folder = profile.articles.create!(:name => 'test folder', :type => 'Folder')

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile, :article_parent_id => folder.id)

    assert_equal folder, a.article_parent
  end

  should 'not have parent if not defined' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    assert_nil a.article_parent
  end

  should 'alert when reference article is removed' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => profile, :requestor => profile)

    article.destroy
    a.reload

    assert_equal "The article was removed.", a.information[:message]
  end

  should 'preserve article_parent' do
    a = ApproveArticle.new(:article_parent => article)

    assert_equal article, a.article_parent
  end

  should 'handle blank names' do
    a = ApproveArticle.create!(:name => '', :article => article, :target => community, :requestor => profile)

    assert_difference article.class, :count do
      a.finish
    end
  end

  should 'notify target if group is moderated' do
    community.moderated_articles = true
    community.save

    a = ApproveArticle.create!(:name => '', :article => article, :target => community, :requestor => profile)
    assert !ActionMailer::Base.deliveries.empty?
  end

  should 'not notify target if group is not moderated' do
    community.moderated_articles = false
    community.save

    a = ApproveArticle.create!(:name => '', :article => article, :target => community, :requestor => profile)
    assert ActionMailer::Base.deliveries.empty?
  end

  should 'copy the source from the original article' do
    article.source = 'sample-feed.com'
    article.save

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal article.class.last.source, article.source
  end

  should 'have a reference article and profile on published article' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    published = article.class.last
    assert_equal [article, community], [published.reference_article, published.profile]
  end

  should 'copy name from original article' do
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 'test name', article.class.last.name
  end

  should 'be able to edit name of generated article' do
    a = ApproveArticle.create!(:name => 'Other name', :article => article, :target => community, :requestor => profile)
    a.abstract = 'Abstract edited';a.save
    a.finish

    assert_equal 'Other name', article.class.last.name
  end

  should 'copy abstract from original article' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 'Lead of article', article.class.last.abstract
  end

  should 'be able to edit abstract of generated article' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.abstract = 'Abstract edited';a.save
    a.finish

    assert_equal 'Abstract edited', article.class.last.abstract
  end

  should 'copy body from original article' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 'This is my article', article.class.last.body
  end

  should 'be able to edit body of generated article' do
    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.body = 'Body edited';a.save
    a.finish

    assert_equal 'Body edited', article.class.last.body
  end

  should 'not be created in blog if community does not have a blog' do
    profile_blog = fast_create(Blog, :profile_id => profile.id)
    article.parent = profile_blog
    article.save

    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert !community.has_blog?
    assert_nil article.class.last.parent
  end

  should 'be created in community blog if came from a blog' do
    profile_blog = fast_create(Blog, :profile_id => profile.id)
    article.parent = profile_blog
    article.save

    community.articles << Blog.new(:profile => community)
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal community.blog, article.class.last.parent
  end

  should 'not be created in community blog if did not come from a blog' do
    profile_folder = fast_create(Folder, :profile_id => profile.id)
    article.parent = profile_folder
    article.save

    blog = fast_create(Blog, :profile_id => community.id)
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_nil article.class.last.parent
  end

  should 'overwrite blog if parent was choosen on published' do
    profile_blog = fast_create(Blog, :profile_id => profile.id)
    article.parent = profile_blog
    article.save

    community.articles << Blog.new(:profile => community)
    community_folder = fast_create(Folder, :profile_id => profile.id)

    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile, :article_parent => community_folder)
    a.finish

    assert_equal community_folder, article.class.last.parent
  end

  should 'use author from original article on published' do
    article.stubs(:last_changed_by_id).returns(profile)

    a = ApproveArticle.create!(:name => 'test name', :article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal profile, article.class.last.author
  end


  should 'use owning profile as author when there is no referenced article' do
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    article.destroy

    assert_equal community, article.class.last.author
  end

  should 'the published article have parent if defined' do
    folder = fast_create(Folder, :profile_id => community.id)
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile, :article_parent => folder)
    a.finish

    assert_equal folder, article.class.last.parent
  end

  should 'copy to_html from reference_article' do
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal article.to_html, article.class.last.to_html
  end

  should 'notify activity on creating published' do
    ActionTracker::Record.delete_all
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal 1, ActionTracker::Record.count
  end

  should 'notify with different trackers activity create with different targets' do
    ActionTracker::Record.delete_all

    article = fast_create(TextileArticle)
    a = ApproveArticle.create!(:name => 'bar', :article => article, :target => community, :requestor => profile)
    a.finish

    article = fast_create(TextileArticle)
    a = ApproveArticle.create!(:name => 'another bar', :article => article, :target => community, :requestor => profile)
    a.finish
    assert_equal 1, ActionTracker::Record.count

    article = fast_create(TextileArticle)
    other_community = fast_create(Community)
    a = ApproveArticle.create!(:name => 'another bar', :article => article, :target => other_community, :requestor => profile)
    a.finish
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify activity on update' do
    ActionTracker::Record.delete_all
    a = ApproveArticle.create!(:name => 'bar', :article => article, :target => community, :requestor => profile)
    a.finish
    assert_equal 1, ActionTracker::Record.count

    published = article.class.last
    published.name = 'foo'
    published.save!
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify with different trackers activity update with different targets' do
    ActionTracker::Record.delete_all
    article1 = fast_create(TextileArticle)
    a = ApproveArticle.create!(:name => 'bar', :article => article1, :target => community, :requestor => profile)
    a.finish

    article2 = fast_create(TinyMceArticle)
    other_community = fast_create(Community)
    a = ApproveArticle.create!(:name => 'another bar', :article => article2, :target => other_community, :requestor => profile)
    a.finish
    assert_equal 2, ActionTracker::Record.count

    published = article1.class.last
    published.name = 'foo';published.save!
    assert_equal 3, ActionTracker::Record.count

    published = article2.class.last
    published.name = 'another foo';published.save!
    assert_equal 4, ActionTracker::Record.count
  end

  should "the tracker action target be defined as Community by custom_target method on articles'creation in communities" do
    ActionTracker::Record.delete_all
    person = fast_create(Person)
    community.add_member(person)

    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal Community, ActionTracker::Record.last.target.class
  end

  should "the tracker action target be defined as person by custom_target method on articles'creation in profile" do
    ActionTracker::Record.delete_all
    person = fast_create(Person)

    a = ApproveArticle.create!(:article => article, :target => person, :requestor => profile)
    a.finish

    assert_equal Person, ActionTracker::Record.last.target.class
  end

  should "have the same is_trackable method as original article" do
    a = ApproveArticle.create!(:article => article, :target => community, :requestor => profile)
    a.finish

    assert_equal article.is_trackable?, article.class.last.is_trackable?
  end


end
