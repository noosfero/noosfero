require File.dirname(__FILE__) + '/../test_helper'

class TinyMceArticleTest < Test::Unit::TestCase

  def setup
    Article.rebuild_index
    @profile = create_user('zezinho').person
  end
  attr_reader :profile
  
  # this test can be removed when we get real tests for TinyMceArticle 
  should 'be an article' do
    assert_subclass TextArticle, TinyMceArticle
  end

  should 'define description' do
    assert_kind_of String, TinyMceArticle.description
  end

  should 'define short description' do
    assert_kind_of String, TinyMceArticle.short_description
  end

  should 'be found when searching for articles by query' do
    tma = TinyMceArticle.create!(:name => 'test tinymce article', :body => '---', :profile => profile)
    assert_includes TinyMceArticle.find_by_contents('article'), tma
    assert_includes Article.find_by_contents('article'), tma
  end

  should 'not sanitize target attribute' do
    article = TinyMceArticle.create!(:name => 'open link in new window', :body => "open <a href='www.invalid.com' target='_blank'>link</a> in new window", :profile => profile)
    assert_tag_in_string article.body, :tag => 'a', :attributes => {:target => '_blank'}
  end

  should 'not translate & to amp; over times' do
    article = TinyMceArticle.create!(:name => 'link', :body => "<a href='www.invalid.com?param1=value&param2=value'>link</a>", :profile => profile)
    assert article.save
    assert_no_match(/&amp;amp;/, article.body)
    assert_match(/&amp;/, article.body)
  end

  should 'not escape comments from tiny mce article body' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "the <!-- comment --> article ...")
    assert_equal "the <!-- comment --> article ...", article.body
  end

  should 'convert entities characters to UTF-8 instead of ISO-8859-1' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'teste ' + Time.now.to_s, :body => '<a title="inform&#225;tica">link</a>')
    assert(article.body.is_utf8?, "%s expected to be valid UTF-8 content" % article.body.inspect)
  end

  should 'fix tinymce mess with itheora comments for IE from tiny mce article body' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "the <!--–-[if IE]--> just for ie... <!--[endif]-->")
    assert_equal "the <!–-[if IE]> just for ie... <![endif]-–>", article.body
  end

  should 'remove iframe if it is not from a trusted site' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://anything/videos.ogg'></iframe>")
    assert_equal "", article.body
  end

  should 'not mess with <iframe and </iframe if it is from itheora by default' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'itheora.org'
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://itheora.org/demo/index.php?v=example.ogv'></iframe>")
    assert_tag_in_string article.body, :tag => 'iframe', :attributes => { :src => "http://itheora.org/demo/index.php?v=example.ogv"}
  end

  should 'allow iframe if it is from stream.softwarelivre.org by default' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'stream.softwarelivre.org'
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://stream.softwarelivre.org/fisl10/sites/default/files/videos.ogg'></iframe>")
    assert_tag_in_string article.body, :tag => 'iframe', :attributes => { :src => "http://stream.softwarelivre.org/fisl10/sites/default/files/videos.ogg"}
  end

  should 'allow iframe if it is from tv.softwarelivre.org by default' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'tv.softwarelivre.org'
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe id='player-base' src='http://tv.softwarelivre.org/embed/1170' width='482' height='406' align='right' frameborder='0' scrolling='no'></iframe>")
    assert_tag_in_string article.body, :tag => 'iframe', :attributes => { :src => "http://tv.softwarelivre.org/embed/1170", :width => "482", :height => "406", :align => "right", :frameborder => "0", :scrolling => "no"}
  end

  should 'allow iframe if it is from a trusted site' do
    env = Environment.default
    env.trusted_sites_for_iframe = ['avideosite.com']
    env.save
    assert_includes Environment.default.trusted_sites_for_iframe, 'avideosite.com'
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://avideosite.com/videos.ogg'></iframe>")
    assert_tag_in_string article.body, :tag => 'iframe', :attributes => { :src => "http://avideosite.com/videos.ogg"}
  end

  should 'remove only the iframe from untrusted site' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://stream.softwarelivre.org/videos.ogg'></iframe><iframe src='http://untrusted_site.com/videos.ogg'></iframe>")
    assert_tag_in_string article.body, :tag => 'iframe', :attributes => { :src => "http://stream.softwarelivre.org/videos.ogg"}
    assert_no_tag_in_string article.body, :tag => 'iframe', :attributes => { :src => "http://untrusted_site.com/videos.ogg"}
  end

  should 'remove iframe if it has 2 or more src' do
    assert_includes Environment.default.trusted_sites_for_iframe, 'itheora.org'

    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<iframe src='http://itheora.org/videos.ogg' src='http://untrusted_site.com/videos.ogg'></iframe>")
    assert_equal '', article.body
  end

  #TinymMCE convert config={"key":(.*)} in config={&quotkey&quot:(.*)}
  should 'not replace &quot with &amp;quot; when adding an Archive.org video' do
    article = TinyMceArticle.create!(:profile => profile, :name => 'article', :abstract => 'abstract', :body => "<embed flashvars='config={&quot;key&quot;:&quot;\#$b6eb72a0f2f1e29f3d4&quot;}'> </embed>")
    assert_equal "<embed flashvars=\"config={&quot;key&quot;:&quot;\#$b6eb72a0f2f1e29f3d4&quot;}\"> </embed>", article.body
  end

  should 'not sanitize html comments' do
    article = TinyMceArticle.new
    article.body = '<p><!-- <asdf> << aasdfa >>> --> <h1> Wellformed html code </h1>'
    article.valid?

    assert_match  /<!-- .* --> <h1> Wellformed html code <\/h1>/, article.body
  end

  should 'not allow XSS on name' do
    article = TinyMceArticle.create!(:name => 'title with <script>alert("xss")</script>', :profile => profile)
    assert_no_match /script/, article.name
  end

  should 'notifiable be true' do
    a = fast_create(TinyMceArticle)
    assert a.notifiable?
  end

  should 'notify activity on create' do
    ActionTracker::Record.delete_all
    TinyMceArticle.create! :name => 'test', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
  end

  should 'notify with different trackers activity create with different targets' do
    ActionTracker::Record.delete_all
    profile = fast_create(Profile)
    TinyMceArticle.create! :name => 'bar', :profile_id => profile.id, :published => true
    TinyMceArticle.create! :name => 'another bar', :profile_id => profile.id, :published => true
    assert_equal 1, ActionTracker::Record.count
    TinyMceArticle.create! :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify activity on update' do
    ActionTracker::Record.delete_all
    a = TinyMceArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a.name = 'foo'
    a.save!
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify with different trackers activity update with different targets' do
    ActionTracker::Record.delete_all
    a1 = TinyMceArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a2 = TinyMceArticle.create! :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
    a1.name = 'foo'
    a1.save!
    assert_equal 3, ActionTracker::Record.count
    a2.name = 'another foo'
    a2.save!
    assert_equal 4, ActionTracker::Record.count
  end

  should 'notify activity on destroy' do
    ActionTracker::Record.delete_all
    a = TinyMceArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 1, ActionTracker::Record.count
    a.destroy
    assert_equal 2, ActionTracker::Record.count
  end

  should 'notify different activities when destroy articles with diferrents targets' do
    ActionTracker::Record.delete_all
    a1 = TinyMceArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a2 = TinyMceArticle.create! :name => 'another bar', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 2, ActionTracker::Record.count
    a1.destroy
    assert_equal 3, ActionTracker::Record.count
    a2.destroy
    assert_equal 4, ActionTracker::Record.count
  end

  should "the tracker action target be defined as Community by custom_target method on articles'creation in communities" do
    ActionTracker::Record.delete_all
    community = fast_create(Community)
    p1 = Person.first
    community.add_member(p1)
    assert p1.is_member_of?(community)
    article = TinyMceArticle.create! :name => 'test', :profile_id => community.id
    assert_equal true, article.published?
    assert_equal true, article.notifiable?
    assert_equal false, article.image?
    assert_equal Community, article.profile.class
    assert_equal Community, ActionTracker::Record.last.target.class
  end

  should "the tracker action target be defined as person by custom_target method on articles'creation in profile" do
    ActionTracker::Record.delete_all
    person = Person.first
    article = TinyMceArticle.create! :name => 'test', :profile_id => person.id
    assert_equal true, article.published?
    assert_equal true, article.notifiable?
    assert_equal false, article.image?
    assert_equal Person, article.profile.class
    assert_equal person, ActionTracker::Record.last.target
  end

  should 'not notify activity if the article is not advertise' do
    ActionTracker::Record.delete_all
    a = TinyMceArticle.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true, :advertise => false
    assert_equal true, a.published?
    assert_equal true, a.notifiable?
    assert_equal false, a.image?
    assert_equal false, a.profile.is_a?(Community)
    assert_equal 0, ActionTracker::Record.count
  end

  should "have defined the is_trackable method defined" do
    assert TinyMceArticle.method_defined?(:is_trackable?)
  end

  should "the common trackable conditions return the correct value" do
    a =  TinyMceArticle.new
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

  should 'tiny mce editor is enabled' do
    assert TinyMceArticle.new.tiny_mce?
  end

end
