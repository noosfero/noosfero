require_relative "../test_helper"

class TextileArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('testing').person
  end
  attr_reader :profile

  should 'provide a proper short description' do
    assert_kind_of String, TextileArticle.short_description
  end

  should 'provide a proper description' do
    assert_kind_of String, TextileArticle.description
  end

  should 'convert Textile to HTML' do
    assert_equal '<p><strong>my text</strong></p>', build(TextileArticle, :body => '*my text*').to_html
  end

  should 'accept empty body' do
    a = TextileArticle.new
    a.expects(:body).returns(nil)
    assert_nothing_raised do
      assert_equal '', a.to_html
    end
  end

  should 'notifiable be true' do
    a = fast_create(TextileArticle)
    assert a.notifiable?
  end

  should 'notify activity on create' do
    ActionTracker::Record.delete_all
    create TextileArticle, :name => 'test', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
  end

  should 'not group trackers activity of article\'s creation' do
    profile = fast_create(Profile)
    assert_difference 'ActionTracker::Record.count', 3 do
      create TextileArticle, :name => 'bar', :profile_id => profile.id, :published => true
      create TextileArticle, :name => 'another bar', :profile_id => profile.id, :published => true
      create TextileArticle, :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    end
  end

  should 'not update activity on update of an article' do
    ActionTracker::Record.delete_all
    profile = fast_create(Profile)
    article = create(TextileArticle, :profile_id => profile.id)
    time = article.activity.updated_at
    Time.stubs(:now).returns(time + 1.day)
    assert_no_difference 'ActionTracker::Record.count' do
      article.name = 'foo'
      article.save!
    end
    assert_equal time, article.activity.updated_at
  end

  should 'not create trackers activity when updating articles' do
    ActionTracker::Record.delete_all
    a1 = create TextileArticle, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a2 = create TextileArticle, :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_no_difference 'ActionTracker::Record.count' do
      a1.name = 'foo';a1.save!
      a2.name = 'another foo';a2.save!
    end
  end

  should 'remove activity after destroying article' do
    ActionTracker::Record.delete_all
    a = create TextileArticle, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_difference 'ActionTracker::Record.count', -1 do
      a.destroy
    end
  end

  should 'remove activity after article is destroyed' do
    ActionTracker::Record.delete_all
    a1 = create TextileArticle, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a2 = create TextileArticle, :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
    assert_difference 'ActionTracker::Record.count', -2 do
      a1.destroy
      a2.destroy
    end
  end

  should "the tracker action target be defined as the article on articles'creation in communities" do
    ActionTracker::Record.delete_all
    community = fast_create(Community)
    p1 = Person.first
    community.add_member(p1)
    assert p1.is_member_of?(community)
    article = create TextileArticle, :name => 'test', :profile_id => community.id
    assert_equal article, ActionTracker::Record.last.target
  end

  should "the tracker action target be defined as the article on articles'creation in profile" do
    ActionTracker::Record.delete_all
    person = Person.first
    article = create TextileArticle, :name => 'test', :profile_id => person.id
    assert_equal article, ActionTracker::Record.last.target
  end

  should 'not notify activity if the article is not advertise' do
    ActionTracker::Record.delete_all
    a = create TextileArticle, :name => 'bar', :profile_id => fast_create(Profile).id, :published => true, :advertise => false
    assert_equal true, a.published?
    assert_equal true, a.notifiable?
    assert_equal false, a.image?
    assert_equal false, a.profile.is_a?(Community)
    assert_equal 0, ActionTracker::Record.count
  end

  should "have defined the is_trackable method defined" do
    assert TextileArticle.method_defined?(:is_trackable?)
  end

  should "the common trackable conditions return the correct value" do
    a =  build(TextileArticle, :profile => profile)
    a.published = a.advertise = true
    assert_equal true, a.published?
    assert_equal true, a.notifiable?
    assert_equal true, a.advertise?
    assert_equal true, a.is_trackable?

    a.published=false
    assert_equal false, a.published?
    assert_equal false, a.is_trackable?

    a.published=true
    a.advertise=false
    assert_equal false, a.advertise?
    assert_equal false, a.is_trackable?
  end

  should 'generate proper HTML for links' do
    assert_tag_in_string build_article('"Noosfero":http://noosfero.org/').to_html, :tag => 'a', :attributes => { :href => 'http://noosfero.org/' }
  end

  should 'not mess up with textile markup' do
    assert_equal '  sqlite> stuff', build_article('  sqlite> stuff').body
    noosfero_cool = '"Noosfero":http://noosfero.org/ is a very cool project'
    assert_equal noosfero_cool, build_article(noosfero_cool).body
  end

  should 'not allow arbitrary HTML' do
    assert_not_equal '<script>alert(1)</script>', build_article('<script>alert(1)</script>').to_html
  end

  should 'not allow Javascript on links' do
    assert_no_tag_in_string build_article('<a href="javascript: alert(\'BOOM\')" onclick="javascript: alert(\'BOOM\')"></a>').to_html, :tag => 'a', :attributes => { :href => /./, :onclick => /./ }
  end

  should 'allow harmless HTML' do
    code = "<pre><code>  code example\n</code></pre>"
    assert_equal code, build_article(code).body
    assert_equal code, build_article(code).to_html
  end

  should 'use Textile markup for lead as well' do
    assert_tag_in_string build_article(nil, :abstract => '"Noosfero":http://noosfero.org/').lead, :tag => 'a', :attributes => { :href => 'http://noosfero.org/' }
  end

  should 'not allow arbitrary HTML in the lead' do
    assert_not_equal '<script>alert(1)</script>', build_article(nil, :abstract => '<script>alert(1)</script>').lead
  end

  should 'not add hard breaks for single line breaks' do
    assert_equal "<p>one\nparagraph</p>", build_article("one\nparagraph").to_html
  end

  should 'have can_display_media_panel with default true' do
    a = TextileArticle.new
    assert a.can_display_media_panel?
  end

  protected

  def build_article(input = nil, options = {})
    article = build(TextileArticle, {:body => input}.merge(options))
    article.valid? # trigger the xss terminate thingy
    article
  end

end
