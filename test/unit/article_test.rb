require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase

  fixtures :environments

  def setup
    @profile = create_user('testing').person
  end
  attr_reader :profile

  should 'have and require an associated profile' do
    a = Article.new
    a.valid?
    assert a.errors.invalid?(:profile_id)

    a.profile = profile
    a.valid?
    assert !a.errors.invalid?(:profile_id)
  end

  should 'require value for name' do
    a = Article.new
    a.valid?
    assert a.errors.invalid?(:name)

    a.name = 'my article'
    a.valid?
    assert !a.errors.invalid?(:name)
  end

  should 'require value for slug and path if name is filled' do
    a = Article.new(:name => 'test article')
    a.slug = nil
    a.path = nil
    a.valid?
    assert a.errors.invalid?(:slug)
    assert a.errors.invalid?(:path)
  end

  should 'not require value for slug and path if name is blank' do
    a = Article.new
    a.valid?
    assert !a.errors.invalid?(:slug)
    assert !a.errors.invalid?(:path)
  end

  should 'act as versioned' do
    a = Article.create!(:name => 'my article', :body => 'my text', :profile_id => profile.id)
    assert_equal 1, a.versions(true).size
    a.name = 'some other name'
    a.save!
    assert_equal 2, a.versions(true).size
  end

  should 'act as taggable' do
    a = Article.create!(:name => 'my article', :profile_id => profile.id)
    a.tag_list = ['one', 'two']
    tags = a.tag_list.names
    assert tags.include?('one')
    assert tags.include?('two')
  end

  should 'act as filesystem' do
    a = Article.create!(:name => 'my article', :profile_id => profile.id)
    b = a.children.build(:name => 'child article', :profile_id => profile.id)
    b.save!
    assert_equal 'my-article/child-article', b.path

    a = Article.find(a.id);
    a.name = 'another name'
    a.save!

    assert_equal 'another-name/child-article', Article.find(b.id).path
  end

  should 'provide HTML version' do
    profile = create_user('testinguser').person
    a = fast_create(Article, :name => 'my article', :profile_id => profile.id)
    a.expects(:body).returns('the body of the article')
    assert_equal 'the body of the article', a.to_html
  end

  should 'provide HTML version when body is nil' do
    a = fast_create(Article, :profile_id => profile.id, :body => nil)
    assert_equal '', a.to_html
  end

  should 'provide first paragraph of HTML version' do
    profile = create_user('testinguser').person
    a = fast_create(Article, :name => 'my article', :profile_id => profile.id)
    a.expects(:body).returns('<p>the first paragraph of the article</p><p>The second paragraph</p>')
    assert_equal '<p>the first paragraph of the article</p>', a.first_paragraph
  end

  should 'inform the icon to be used' do
    assert_equal 'text-html', Article.new.icon_name
  end

  should 'provide a (translatable) description' do
    result = 'the description'

    a = Article.new
    a.expects(:_).returns(result)
    assert_same result, a.mime_type_description
  end

  should 'not accept articles with same slug under the same level' do

    # top level articles first
    profile = create_user('testinguser').person
    a1 = profile.articles.build(:name => 'test')
    a1.save!

    # cannot add another top level article with same slug
    a2 = profile.articles.build(:name => 'test')
    a2.valid?
    assert a2.errors.invalid?(:slug)

    # now create a child of a1
    a3 = profile.articles.build(:name => 'test')
    a3.parent = a1
    a3.valid?
    assert !a3.errors.invalid?(:slug)
    a3.save!

    # cannot add another child of a1 with same slug
    a4 = profile.articles.build(:name => 'test')
    a4.parent = a1
    a4.valid?
    assert a4.errors.invalid?(:slug)
  end

  should 'record who did the last change' do
    a = profile.articles.build(:name => 'test')

    # must be a person
    assert_raise ActiveRecord::AssociationTypeMismatch do
      a.last_changed_by = Profile.new
    end
    assert_nothing_raised do
      a.last_changed_by = Person.new
      a.save!
    end
  end

  should 'search for recent documents' do
    other_profile = create_user('otherpropfile').person

    Article.destroy_all

    first = fast_create(TextArticle, :profile_id => profile.id, :name => 'first')
    second = fast_create(TextArticle, :profile_id => profile.id, :name => 'second')
    third = fast_create(TextArticle, :profile_id => profile.id, :name => 'third')
    fourth = fast_create(TextArticle, :profile_id => profile.id, :name => 'fourth')
    fifth = fast_create(TextArticle, :profile_id => profile.id, :name => 'fifth')

    other_first = other_profile.articles.build(:name => 'first'); other_first.save!
    
    assert_equal [other_first, fifth, fourth], Article.recent(3)
    assert_equal [other_first, fifth, fourth, third, second, first], Article.recent(6)
  end

  should 'not show private documents as recent' do
    p = create_user('usr1').person
    Article.destroy_all

    first  = fast_create(TextArticle, :profile_id => p.id, :name => 'first',  :published => true)
    second = fast_create(TextArticle, :profile_id => p.id, :name => 'second', :published => false)

    assert_equal [ first ], Article.recent(nil)
  end

  should 'not show unpublished documents as recent' do
    p = create_user('usr1').person
    Article.destroy_all

    first  = fast_create(TextArticle, :profile_id => p.id, :name => 'first',  :published => true)
    second = fast_create(TextArticle, :profile_id => p.id, :name => 'second', :published => false)

    assert_equal [ first ], Article.recent(nil)
  end

  should 'not show documents from a private profile as recent' do
    p = fast_create(Person, :public_profile => false)
    Article.destroy_all

    first  = fast_create(TextArticle, :profile_id => p.id, :name => 'first',  :published => true)
    second = fast_create(TextArticle, :profile_id => p.id, :name => 'second', :published => false)

    assert_equal [ ], Article.recent(nil)
  end

  should 'not show documents from a invisible profile as recent' do
    p = fast_create(Person, :visible => false)
    Article.destroy_all

    first  = fast_create(TextArticle, :profile_id => p.id, :name => 'first',  :published => true)
    second = fast_create(TextArticle, :profile_id => p.id, :name => 'second', :published => false)

    assert_equal [ ], Article.recent(nil)
  end

  should 'order recent articles by published_at' do
    p = create_user('usr1').person
    Article.destroy_all

    now = Time.now

    first  = p.articles.build(:name => 'first',  :published => true, :created_at => now, :published_at => now);  first.save!
    second = p.articles.build(:name => 'second', :published => true, :updated_at => now, :published_at => now + 1.second); second.save!

    assert_equal [ second, first ], Article.recent(2)

    Article.record_timestamps = false
    first.update_attributes!(:published_at => second.published_at + 1.second)
    Article.record_timestamps = true

    assert_equal [ first, second ], Article.recent(2)
  end

  should 'not show UploadedFile as recent' do
    p = create_user('usr1').person
    Article.destroy_all

    first = UploadedFile.new(:profile => p, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'));  first.save!
    second = fast_create(TextArticle, :profile_id => p.id, :name => 'second')

    assert_equal [ second ], Article.recent(nil)
  end

  should 'not show RssFeed as recent' do
    p = create_user('usr1').person
    Article.destroy_all
    first = fast_create(RssFeed, :profile_id => p.id, :name => 'my feed', :advertise => true)
    first.limit = 10; first.save!
    second = p.articles.build(:name => 'second'); second.save!

    assert_equal [ second ], Article.recent(nil)
  end

  should 'not show blog as recent' do
    p = create_user('usr1').person
    Article.destroy_all
    first = fast_create(Blog, :profile_id => p.id, :name => 'my blog', :advertise => true)
    second = p.articles.build(:name => 'second'); second.save!

    assert_equal [ second ], Article.recent(nil)
  end

  should 'accept extra conditions to find recent' do
    p = create_user('usr1').person
    Article.destroy_all
    a1 = p.articles.create!(:name => 'first')
    a2 = p.articles.create!(:name => 'second')

    assert_equal [ a1 ], Article.recent(nil, :name => 'first')
  end

  should 'require that subclasses define description' do
    assert_raise NotImplementedError do
      Article.description
    end
  end

  should 'require that subclasses define short description' do
    assert_raise NotImplementedError do
      Article.short_description
    end
  end

  should 'indicate wheter children articles are allowed or not' do
    assert_equal true, Article.new.allow_children?
  end

  should 'provide a url to itself' do
    article = profile.articles.build(:name => 'myarticle')
    article.save!

    assert_equal(profile.url.merge(:page => ['myarticle']), article.url)
  end

  should 'provide a url to itself having a parent topic' do
    parent = profile.articles.build(:name => 'parent');  parent.save!
    child = profile.articles.build(:name => 'child', :parent => parent); child.save!

    assert_equal(profile.url.merge(:page => [ 'parent', 'child']), child.url)
  end

  should 'associate with categories' do
    env = Environment.default
    c1 = env.categories.build(:name => "test category 1"); c1.save!
    c2 = env.categories.build(:name => "test category 2"); c2.save!

    article = profile.articles.build(:name => 'withcategories')
    article.save!

    article.add_category c1
    article.add_category c2

    assert_equivalent [c1,c2], article.categories(true)
  end

  should 'remove comments when removing article' do
    assert_no_difference Comment, :count do
      a = profile.articles.build(:name => 'test article')
      a.save!

      assert_difference Comment, :count, 1 do
        comment = a.comments.build
        comment.author = profile
        comment.title = 'test comment'
        comment.body = 'you suck!'
        comment.save!
      end

      a.destroy
    end
  end

  should 'list most commented articles' do
    Article.delete_all

    person = create_user('testuser').person
    articles = (1..4).map {|n| a = person.articles.build(:name => "art #{n}"); a.save!; a }

    2.times { articles[0].comments.build(:title => 'test', :body => 'asdsad', :author => person).save! }
    4.times { articles[1].comments.build(:title => 'test', :body => 'asdsad', :author => person).save! }

    # should respect the order (more commented comes first)
    assert_equal [articles[1], articles[0]], person.articles.most_commented(2)
  end

  should 'identify itself as a non-folder' do
    assert !Article.new.folder?, 'should identify itself as non-folder'
  end

  should 'identify itself as a non-blog' do
    assert !Article.new.blog?, 'should identify itself as non-blog'
  end

  should 'always display if public content' do
    person = create_user('testuser').person
    assert_equal true, person.home_page.display_to?(nil)
  end

  should 'display to owner' do
    # a person with private contents ...
    person = create_user('testuser').person
    person.update_attributes!(:public_content => false)

    # ... can see his own articles
    a = person.articles.create!(:name => 'test article')
    assert_equal true, a.display_to?(person)
  end

  should 'reindex when comments are changed' do
    a = Article.new
    a.expects(:ferret_update)
    a.comments_updated
  end

  should 'index comments title together with article' do
    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!
    c1 = art.comments.build(:title => 'a nice comment', :body => 'anything', :author => owner); c1.save!

    assert_includes Article.find_by_contents('nice'), art
  end

  should 'index comments body together with article' do
    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!
    c1 = art.comments.build(:title => 'test comment', :body => 'anything', :author => owner); c1.save!

    assert_includes Article.find_by_contents('anything'), art
  end

  should 'cache children count' do
    owner = create_user('testuser').person
    art = owner.articles.build(:name => 'ytest'); art.save!

    # two children articles
    art.children.create!(:profile => owner, :name => 'c1')
    art.children.create!(:profile => owner, :name => 'c2')

    art.reload

    assert_equal 2, art.children_count
    assert_equal 2, art.children.size

  end

  should 'categorize in the entire category hierarchy' do
    c1 = Category.create!(:environment => Environment.default, :name => 'c1')
    c2 = c1.children.create!(:environment => Environment.default, :name => 'c2')
    c3 = c2.children.create!(:environment => Environment.default, :name => 'c3')

    owner = create_user('testuser').person
    art = owner.articles.create!(:name => 'ytest')

    art.add_category(c3)

    assert_equal [c3], art.categories(true)
    assert_equal [art], c2.articles(true)

    assert_includes c3.articles(true), art
    assert_includes c2.articles(true), art
    assert_includes c1.articles(true), art
  end

  should 'redefine the entire category set at once' do
    c1 = Category.create!(:environment => Environment.default, :name => 'c1')
    c2 = c1.children.create!(:environment => Environment.default, :name => 'c2')
    c3 = c2.children.create!(:environment => Environment.default, :name => 'c3')
    c4 = c1.children.create!(:environment => Environment.default, :name => 'c4')
    owner = create_user('testuser').person
    art = owner.articles.create!(:name => 'ytest')

    art.add_category(c4)

    art.category_ids = [c2,c3].map(&:id)

    assert_equivalent [c2, c3], art.categories(true)
  end

  should 'be able to create an article already with categories' do
    c1 = fast_create(Category, :environment_id => Environment.default.id, :name => 'c1')
    c2 = fast_create(Category, :environment_id => Environment.default.id, :name => 'c2')

    p = create_user('testinguser').person
    a = p.articles.create!(:name => 'test', :category_ids => [c1.id, c2.id])

    assert_equivalent [c1, c2], a.categories(true)
  end

  should 'not add a category twice to article' do
    c1 = fast_create(Category, :environment_id => Environment.default.id, :name => 'c1')
    c2 = c1.children.create!(:environment => Environment.default, :name => 'c2')
    c3 = c1.children.create!(:environment => Environment.default, :name => 'c3')
    owner = create_user('testuser').person
    art = owner.articles.create!(:name => 'ytest')
    art.category_ids = [c2,c3,c3].map(&:id)
    assert_equal [c2, c3], art.categories(true)
  end

  should 'not accept Product category as category' do
    assert !Article.new.accept_category?(ProductCategory.new)
  end

  should 'accept published attribute' do
    assert_respond_to Article.new, :published
    assert_respond_to Article.new, :published=
  end

  should 'say that logged off user cannot see private article' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    article = fast_create(Article, :name => 'test article', :profile_id => profile.id, :published => false)

    assert !article.display_to?(nil)
  end 
  
  should 'say that not member of profile cannot see private article' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    article = fast_create(Article, :name => 'test article', :profile_id => profile.id, :published => false)
    person = create_user('test_user').person

    assert !article.display_to?(person)
  end
  
  should 'say that member user can not see private article' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    article = fast_create(Article, :name => 'test article', :profile_id => profile.id, :published => false)
    person = create_user('test_user').person
    profile.affiliate(person, Profile::Roles.member(profile.environment.id))

    assert !article.display_to?(person)
  end

  should 'say that profile admin can see private article' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    article = fast_create(Article, :name => 'test article', :profile_id => profile.id, :published => false)
    person = create_user('test_user').person
    profile.affiliate(person, Profile::Roles.admin(profile.environment.id))

    assert article.display_to?(person)
  end

  should 'say that profile moderator can see private article' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    article = fast_create(Article, :name => 'test article', :profile_id => profile.id, :published => false)
    person = create_user('test_user').person
    profile.affiliate(person, Profile::Roles.moderator(profile.environment.id))

    assert article.display_to?(person)
  end

  should 'not show article to non member if article public but profile private' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile', :public_profile => false)
    article = fast_create(Article, :name => 'test article', :profile_id => profile.id, :published => true)
    person1 = create_user('test_user1').person
    profile.affiliate(person1, Profile::Roles.member(profile.environment.id))
    person2 = create_user('test_user2').person

    assert !article.display_to?(nil)
    assert !article.display_to?(person2)
    assert article.display_to?(person1)
  end

  should 'make new article private if created inside a private folder' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    folder = fast_create(Folder, :name => 'my_intranet', :profile_id => profile.id, :published => false)
    article = fast_create(Article, :name => 'my private article', :profile_id => profile.id, :parent_id => folder.id)

    assert !article.published?
  end

  should 'save as private' do
    profile = fast_create(Profile, :name => 'test profile', :identifier => 'test_profile')
    folder = fast_create(Folder, :name => 'my_intranet', :profile_id => profile.id, :published => false)
    article = fast_create(Article, :name => 'my private article')
    article.profile = profile
    article.parent = folder
    article.save!
    article.reload

    assert !article.published?
  end

  should 'not allow friends of private person see the article' do
    person = create_user('test_user').person
    article = Article.create!(:name => 'test article', :profile => person, :published => false)
    friend = create_user('test_friend').person
    person.add_friend(friend)
    person.save!
    friend.save!

    assert !article.display_to?(friend)
  end

  should 'display private articles to people who can view private content' do
    person = create_user('test_user').person
    article = fast_create(Article, :name => 'test article', :profile_id => person.id, :published => false)

    admin_user = create_user('admin_user').person
    admin_user.stubs(:has_permission?).with('view_private_content', article.profile).returns('true')

    assert article.display_to?(admin_user)
  end

  should 'make a copy of the article as child of it' do
    person = create_user('test_user').person
    a = person.articles.create!(:name => 'test article', :body => 'some text')
    b = a.copy(:parent => a, :profile => a.profile)
    
    assert_includes a.children, b
    assert_equal 'some text', b.body
  end

  should 'make a copy of the article to other profile' do
    p1 = create_user('test_user1').person
    p2 = create_user('test_user2').person
    a = p1.articles.create!(:name => 'test article', :body => 'some text')
    b = a.copy(:parent => a, :profile => p2)

    p2 = Person.find(p2.id)
    assert_includes p2.articles, b
    assert_equal 'some text', b.body
  end

  should 'mantain the type in a copy' do
    p = create_user('test_user').person
    a = fast_create(Folder, :name => 'test folder', :profile_id => p.id)
    b = a.copy(:parent => a, :profile => p)

    assert_kind_of Folder, b
  end

  should 'copy slug' do
    a = fast_create(Article, :slug => 'slug123')
    b = a.copy({})
    assert_equal a.slug, b.slug
  end

  should 'load article under an old path' do
    p = create_user('test_user').person
    a = p.articles.create(:name => 'old-name')
    old_path = a.explode_path
    a.name = 'new-name'
    a.save!

    page = Article.find_by_old_path(old_path)

    assert_equal a.path, page.path
  end

  should 'load new article name equal of another article old name' do
    p = create_user('test_user').person
    a1 = p.articles.create!(:name => 'old-name')
    old_path = a1.explode_path
    a1.name = 'new-name'
    a1.save!
    a2 = p.articles.create!(:name => 'old-name')

    page = Article.find_by_old_path(old_path)

    assert_equal a2.path, page.path
  end

  should 'article with most recent version with the name must be loaded if no aritcle with the name' do
    p = create_user('test_user').person
    a1 = p.articles.create!(:name => 'old-name')
    old_path = a1.explode_path
    a1.name = 'new-name'
    a1.save!
    a2 = p.articles.create!(:name => 'old-name')
    a2.name = 'other-new-name'
    a2.save!

    page = Article.find_by_old_path(old_path)

    assert_equal a2.path, page.path
  end

  should 'not return an article of a different user' do
    p1 = create_user('test_user').person
    a = p1.articles.create!(:name => 'old-name')
    old_path = a.explode_path
    a.name = 'new-name'
    a.save!

    p2 = create_user('another_user').person

    page = p2.articles.find_by_old_path(old_path)

    assert_nil page
  end

  should 'identify if belongs to blog' do
    p = create_user('user_blog_test').person
    blog = fast_create(Blog, :name => 'Blog test', :profile_id => p.id)
    post = fast_create(TextileArticle, :name => 'First post', :profile_id => p.id, :parent_id => blog.id)
    assert post.belongs_to_blog?
  end

  should 'not belongs to blog' do
    p = create_user('user_blog_test').person
    folder = fast_create(Folder, :name => 'Not Blog', :profile_id => p.id)
    a = fast_create(TextileArticle, :name => 'Not blog post', :profile_id => p.id, :parent_id => folder.id)
    assert !a.belongs_to_blog?
  end

  should 'has comments notifier true by default' do
    a = Article.new
    assert a.notify_comments?
  end

  should 'hold hits count' do
    a = fast_create(Article, :name => 'Test article', :profile_id => profile.id)
    a.hits = 10
    a.save!
    a.reload
    assert_equal 10, a.hits
  end

  should 'increment hit counter when hitted' do
    a = fast_create(Article, :name => 'Test article', :profile_id => profile.id, :hits => 10)
    a.hit
    assert_equal 11, a.hits
    a.reload
    assert_equal 11, a.hits
  end

  should 'have display_hits setting with default true' do
    a = fast_create(Article, :name => 'Test article', :profile_id => profile.id)
    assert_respond_to a, :display_hits
    assert_equal true, a.display_hits
  end

  should 'can display hits' do
    a = fast_create(Article, :name => 'Test article', :profile_id => profile.id)
    assert_respond_to a, :can_display_hits?
    assert_equal true, a.can_display_hits?
  end

  should 'return a view url when image' do
    image = UploadedFile.create!(:profile => profile, :uploaded_data => fixture_file_upload('/files/rails.png', 'image/png'))

    assert_equal image.url.merge(:view => true), image.view_url
  end

  should 'not return a view url when common article' do
    a = fast_create(Article, :name => 'Test article', :profile_id => profile.id)

    assert_equal a.url, a.view_url
  end

  should 'know its author' do
    assert_equal profile, Article.new(:last_changed_by => profile).author
  end

  should 'use owning profile as author when we dont know who did the last change' do
    assert_equal profile, Article.new(:last_changed_by => nil, :profile => profile).author
  end

  should 'have published_at' do
    assert_respond_to Article.new, :published_at
  end

  should 'published_at is same as created_at if not set' do
    a = fast_create(Article, :name => 'Published at', :profile_id => profile.id)
    assert_equal a.created_at, a.published_at
  end

  should 'use npage to compose cache key' do
    a = fast_create(Article, :name => 'Published at', :profile_id => profile.id)
    assert_match(/-npage-2/,a.cache_key(:npage => 2))
  end

  should 'use year and month to compose cache key' do
    a = fast_create(Article, :name => 'Published at', :profile_id => profile.id)
    assert_match(/-year-2009-month-04/, a.cache_key(:year => '2009', :month => '04'))
  end

  should 'not be highlighted by default' do
    a = Article.new
    assert !a.highlighted
  end

  should 'get tagged with tag' do
    a = create(Article, :name => 'Published at', :profile_id => profile.id, :tag_list => 'bli')
    as = Article.find_tagged_with('bli')

    assert_includes as, a
  end

  should 'not get tagged with tag from other environment' do
    article_from_this_environment = create(Article, :profile => profile, :tag_list => 'bli')

    other_environment = fast_create(Environment)
    user_from_other_environment = create_user('other_user', :environment => other_environment).person
    article_from_other_enviroment = create(Article, :profile => user_from_other_environment, :tag_list => 'bli')

    tagged_articles_in_other_environment = other_environment.articles.find_tagged_with('bli')

    assert_includes tagged_articles_in_other_environment, article_from_other_enviroment
    assert_not_includes tagged_articles_in_other_environment, article_from_this_environment
  end

  should 'ignore category with zero as id' do
    a = profile.articles.create!(:name => 'a test article')
    c = fast_create(Category, :name => 'test category', :environment_id => profile.environment.id)
    a.category_ids = ['0', c.id, nil]
    assert a.save
    assert_equal [c], a.categories
  end

  should 'add owner on cache_key when has profile' do
    a = profile.articles.create!(:name => 'a test article')
    assert_match(/-owner/, a.cache_key({}, profile))
  end

  should 'not add owner on cache_key when has no profile' do
    a = profile.articles.create!(:name => 'a test article')
    assert_no_match(/-owner/, a.cache_key({}))
  end

  should 'add owner on cache_key when profile is community' do
    c = fast_create(Community)
    a = c.articles.create!(:name => 'a test article')
    assert_match(/-owner/, a.cache_key({}, c))
  end

  should 'have a creator method' do
    c = fast_create(Community)
    a = c.articles.create!(:name => 'a test article', :last_changed_by => profile)
    p = create_user('other_user').person
    a.update_attributes(:body => 'some content', :last_changed_by => p); a.save!
    assert_equal profile, a.creator
  end

  should 'allow creator to edit if is publisher' do
    c = fast_create(Community)
    p = create_user_with_permission('test_user', 'publish_content', c)
    a = c.articles.create!(:name => 'a test article', :last_changed_by => p)

    assert a.allow_post_content?(p)
  end

  should 'allow user with "Manage content" permissions to edit' do
    c = fast_create(Community)
    p = create_user_with_permission('test_user', 'post_content', c)
    a = c.articles.create!(:name => 'a test article')

    assert a.allow_post_content?(p)
  end

  should 'update slug from name' do
    article = Article.create!(:name => 'A test article', :profile_id => profile.id)
    assert_equal 'a-test-article', article.slug
    article.name = 'Changed name'
    assert_equal 'changed-name', article.slug
  end

  should 'find articles in a specific category' do
    env = Environment.default
    category_with_articles = env.categories.create!(:name => "Category with articles")
    category_without_articles = env.categories.create!(:name => "Category without articles")

    article_in_category = profile.articles.create!(:name => 'Article in category')

    article_in_category.add_category(category_with_articles)

    assert_includes profile.articles.in_category(category_with_articles), article_in_category
    assert_not_includes profile.articles.in_category(category_without_articles), article_in_category
  end

  should 'has external_link attr' do
    assert_nothing_raised NoMethodError do
      Article.new(:external_link => 'http://some.external.link')
    end
  end

  should 'validates format of external_link' do
    article = Article.new(:external_link => 'http://invalid-url')
    article.valid?
    assert_not_nil article.errors[:external_link]
  end

  should 'put http in external_link' do
    article = Article.new(:external_link => 'url.without.http')
    assert_equal 'http://url.without.http', article.external_link
  end

  should 'list only published articles' do
    profile = fast_create(Person)

    published  = profile.articles.create(:name => 'Published',  :published => true)
    unpublished = profile.articles.create(:name => 'Unpublished', :published => false)

    assert_equal [ published ], profile.articles.published
  end

  should 'sanitize tags after save article' do
    article = fast_create(Article, :slug => 'article-with-tags', :profile_id => profile.id)
    article.tags << Tag.new(:name => "TV Web w<script type='javascript'></script>")
    assert_match /[<>]/, article.tags.last.name
    article.save!
    assert_no_match /[<>]/, article.tags.last.name
  end

  should 'strip HTML from tag names after save article' do
    article = fast_create(Article, :slug => 'article-with-tags', :profile_id => profile.id)
    article.tags << Tag.new(:name => "TV Web w<script type=...")
    assert_match /</, article.tags.last.name
    article.save!
    assert_no_match /</, article.tags.last.name
  end

  should 'sanitize name before validation' do
    article = Article.new
    article.name = "<h1 Bla </h1>"
    article.valid?

    assert_no_match /<[^>]*</, article.name
  end

  should 'not doubly escape quotes in the name' do
    profile = fast_create(Profile)
    a = fast_create(Article, :profile_id => profile.id)
    p = PublishedArticle.create!(:reference_article => a, :profile => fast_create(Community))

    p.name = 'title with "quotes"'
    p.save
    assert_equal 'title with "quotes"', p.name
  end

  should 'remove script tags from name' do
    a = Article.new(:name => 'hello <script>alert(1)</script>')
    a.valid?

    assert_no_match(/<script>/, a.name)
  end

  should 'escape malformed html tags' do
    article = Article.new
    article.name = "<h1 Malformed >> html >< tag"
    article.valid?

    assert_no_match /[<>]/, article.name
  end

  should 'return truncated title in short_title' do
    article = Article.new
    article.name = 'a123456789abcdefghij'
    assert_equal 'a123456789ab...', article.short_title
  end

  should 'return abstract as lead' do
    a = Article.new(:abstract => 'lead')
    assert_equal 'lead', a.lead
  end

  should 'return first paragraph as lead by default' do
    a = Article.new
    a.stubs(:first_paragraph).returns('<p>first</p>')
    assert_equal '<p>first</p>', a.lead
  end

  should 'return first paragraph as lead with empty but non-null abstract' do
    a = Article.new(:abstract => '')
    a.stubs(:first_paragraph).returns('<p>first</p>')
    assert_equal '<p>first</p>', a.lead
  end

  should 'return blank as lead when article has no paragraphs' do
    a = Article.new(:body => "<div>an article with content <em>but without</em> a paragraph</div>")
    assert_equal '', a.lead
  end

  should 'track action when a published article is created outside a community' do
    article = TinyMceArticle.create! :name => 'Tracked Article', :profile_id => profile.id
    assert article.published?
    assert_kind_of Person, article.profile
    ta = ActionTracker::Record.last
    assert_equal 'Tracked Article', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert_kind_of Person, ta.user
    ta.back_in_time(26.hours)
    article = TinyMceArticle.create! :name => 'Another Tracked Article', :profile_id => profile.id
    ta = ActionTracker::Record.last
    assert_equal ['Another Tracked Article'], ta.get_name
    assert_equal [article.url], ta.get_url
  end

  should 'track action when a published article is created in a community' do
    community = fast_create(Community)
    p1 = ActionTracker::Record.current_user_from_model 
    p2 = fast_create(Person)
    p3 = fast_create(Person)
    community.add_member(p1)
    community.add_member(p2)
    assert p1.is_member_of?(community)
    assert p2.is_member_of?(community)
    assert !p3.is_member_of?(community)
    Article.destroy_all
    ActionTracker::Record.destroy_all
    article = TinyMceArticle.create! :name => 'Tracked Article', :profile_id => community.id
    assert article.published?
    assert_kind_of Community, article.profile
    ta = ActionTracker::Record.last
    assert_equal 'Tracked Article', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert_kind_of Person, ta.user
    process_delayed_job_queue
    assert_equal 3, ActionTrackerNotification.count
    ActionTrackerNotification.all.map{|a|a.profile}.map do |profile|
      assert [p1,p2,community].include?(profile)
    end
  end

  should 'track action when a published article is updated' do
    a = TinyMceArticle.create! :name => 'a', :profile_id => profile.id
    a.update_attributes! :name => 'b'
    ta = ActionTracker::Record.last
    assert_equal ['b'], ta.get_name
    assert_equal [a.reload.url], ta.get_url
    a.update_attributes! :name => 'c'
    ta = ActionTracker::Record.last
    assert_equal ['b','c'], ta.get_name
    assert_equal [a.url,a.reload.url], ta.get_url
    a.update_attributes! :body => 'test'
    ta = ActionTracker::Record.last
    assert_equal ['b','c','c'], ta.get_name
    assert_equal [a.url,a.reload.url,a.reload.url], ta.get_url
    a.update_attributes! :hits => 50
    ta = ActionTracker::Record.last
    assert_equal ['b','c','c'], ta.get_name
    assert_equal [a.url,a.reload.url,a.reload.url], ta.get_url
  end

  should 'track action when a published article is removed' do
    a = TinyMceArticle.create! :name => 'a', :profile_id => profile.id
    a.destroy
    ta = ActionTracker::Record.last
    assert_equal ['a'], ta.get_name
    a = TinyMceArticle.create! :name => 'b', :profile_id => profile.id
    a.destroy
    ta = ActionTracker::Record.last
    assert_equal ['a','b'], ta.get_name
    a = TinyMceArticle.create! :name => 'c', :profile_id => profile.id, :published => false
    a.destroy
    ta = ActionTracker::Record.last
    assert_equal ['a','b'], ta.get_name
  end

  should 'notifiable is false by default' do
    a = fast_create(Article)
    assert !a.notifiable?
  end

  should 'not notify activity by default on create' do
    ActionTracker::Record.delete_all
    Article.create! :name => 'test', :profile_id => fast_create(Profile).id, :published => true
    assert_equal 0, ActionTracker::Record.count
  end

  should 'not notify activity by default on update' do
    ActionTracker::Record.delete_all
    a = Article.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a.name = 'foo'
    a.save!
    assert_equal 0, ActionTracker::Record.count
  end

  should 'not notify activity by default on destroy' do
    ActionTracker::Record.delete_all
    a = Article.create! :name => 'bar', :profile_id => fast_create(Profile).id, :published => true
    a.destroy
    assert_equal 0, ActionTracker::Record.count
  end

  should "the action_tracker_target method be defined" do
    assert Article.method_defined?(:action_tracker_target)
  end

  should "the action_tracker_target method return the article profile" do
    profile = fast_create(Person)
    article = fast_create(Article, :profile_id => profile.id)
    assert_equal profile, article.action_tracker_target

    profile = fast_create(Community)
    article = fast_create(Article, :profile_id => profile.id)
    assert_equal profile, article.action_tracker_target
  end

  should "have defined the is_trackable method defined" do
    assert Article.method_defined?(:is_trackable?)
  end

  should "the common trackable conditions return the correct value" do
    a =  Article.new
    a.published = a.advertise = true
    assert_equal true, a.published?
    assert_equal false, a.notifiable?
    assert_equal true, a.advertise?
    assert_equal false, a.is_trackable?
   
    a.published=false
    assert_equal false, a.published?
    assert_equal false, a.is_trackable?

    a.published=true
    a.advertise=false
    assert_equal false, a.advertise?
    assert_equal false, a.is_trackable?
  end

  should 'not create more than one notification track action to community when update more than one artile' do
    community = fast_create(Community)
    p1 = Person.first || fast_create(Person)
    community.add_member(p1)
    assert p1.is_member_of?(community)
    Article.destroy_all
    ActionTracker::Record.destroy_all
    article = TinyMceArticle.create! :name => 'Tracked Article 1', :profile_id => community.id
    assert article.published?
    assert_kind_of Community, article.profile
    assert_equal 1, ActionTracker::Record.count
    ta = ActionTracker::Record.last
    assert_equal 'Tracked Article 1', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert p1, ta.user
    assert community, ta.target
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count

    article = TinyMceArticle.create! :name => 'Tracked Article 2', :profile_id => community.id
    assert article.published?
    assert_kind_of Community, article.profile
    assert_equal 1, ActionTracker::Record.count
    ta = ActionTracker::Record.last
    assert_equal 'Tracked Article 2', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert_equal p1, ta.user
    assert_equal community, ta.target
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count
  end

  should 'create the notification to the member when one member has the notification and the other no' do
    community = fast_create(Community)
    p1 = Person.first || fast_create(Person)
    community.add_member(p1)
    assert p1.is_member_of?(community)
    Article.destroy_all
    ActionTracker::Record.destroy_all
    article = TinyMceArticle.create! :name => 'Tracked Article 1', :profile_id => community.id
    assert article.published?
    assert_kind_of Community, article.profile
    assert_equal 1, ActionTracker::Record.count
    ta = ActionTracker::Record.first
    assert_equal 'Tracked Article 1', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert p1, ta.user
    assert community, ta.target
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count

    p2 = fast_create(Person)
    community.add_member(p2)
    process_delayed_job_queue
    assert_equal 5, ActionTrackerNotification.count

    article = TinyMceArticle.create! :name => 'Tracked Article 2', :profile_id => community.id
    assert article.published?
    assert_kind_of Community, article.profile
    assert_equal 3, ActionTracker::Record.count
    ta = ActionTracker::Record.first
    assert_equal 'Tracked Article 2', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert_equal p1, ta.user
    assert_equal community, ta.target
    process_delayed_job_queue
    assert_equal 6, ActionTrackerNotification.count
  end

  should 'not create more than one notification track action to friends when update more than one artile' do
    p1 = Person.first || fast_create(Person)
    friend = fast_create(Person)
    p1.add_friend(friend)
    Article.destroy_all
    ActionTracker::Record.destroy_all
    ActionTrackerNotification.destroy_all
    article = TinyMceArticle.create! :name => 'Tracked Article 1', :profile_id => p1.id
    assert article.published?
    assert_kind_of Person, article.profile
    assert_equal 1, ActionTracker::Record.count
    ta = ActionTracker::Record.last
    assert_equal 'Tracked Article 1', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert p1, ta.user
    assert p1, ta.target
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count

    article = TinyMceArticle.create! :name => 'Tracked Article 2', :profile_id => p1.id
    assert article.published?
    assert_kind_of Person, article.profile
    assert_equal 1, ActionTracker::Record.count
    ta = ActionTracker::Record.last
    assert_equal 'Tracked Article 2', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert_equal p1, ta.user
    assert_equal p1, ta.target
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count
  end

  should 'create the notification to the friend when one friend has the notification and the other no' do
    p1 = Person.first || fast_create(Person)
    f1 = fast_create(Person)
    p1.add_friend(f1)
    Article.destroy_all
    ActionTracker::Record.destroy_all
    ActionTrackerNotification.destroy_all
    article = TinyMceArticle.create! :name => 'Tracked Article 1', :profile_id => p1.id
    assert article.published?
    assert_kind_of Person, article.profile
    assert_equal 1, ActionTracker::Record.count
    ta = ActionTracker::Record.first
    assert_equal 'Tracked Article 1', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert p1, ta.user
    assert p1, ta.target
    process_delayed_job_queue
    assert_equal 2, ActionTrackerNotification.count

    f2 = fast_create(Person)
    p1.add_friend(f2)
    process_delayed_job_queue
    assert_equal 5, ActionTrackerNotification.count
    article = TinyMceArticle.create! :name => 'Tracked Article 2', :profile_id => p1.id
    assert article.published?
    assert_kind_of Person, article.profile
    assert_equal 2, ActionTracker::Record.count
    ta = ActionTracker::Record.first
    assert_equal 'Tracked Article 2', ta.get_name.last
    assert_equal article.url, ta.get_url.last
    assert_equal p1, ta.user
    assert_equal p1, ta.target
    process_delayed_job_queue
    assert_equal 6, ActionTrackerNotification.count
  end

end
