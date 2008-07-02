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

  should 'require values for name, slug and path' do
    a = Article.new
    a.valid?
    assert a.errors.invalid?(:name)
    assert a.errors.invalid?(:slug)
    assert a.errors.invalid?(:path)

    a.name = 'my article'
    a.valid?
    assert !a.errors.invalid?(:name)
    assert !a.errors.invalid?(:name)
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
    a = Article.create!(:name => 'my article', :profile_id => profile.id)
    a.expects(:body).returns('the body of the article')
    assert_equal 'the body of the article', a.to_html
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

    first = profile.articles.build(:name => 'first'); first.save!
    second = profile.articles.build(:name => 'second'); second.save!
    third = profile.articles.build(:name => 'third'); third.save!
    fourth = profile.articles.build(:name => 'fourth'); fourth.save!
    fifth = profile.articles.build(:name => 'fifth'); fifth.save!

    other_first = other_profile.articles.build(:name => 'first'); other_first.save!
    
    assert_equal [other_first, fifth, fourth], Article.recent(3)
    assert_equal [other_first, fifth, fourth, third, second, first], Article.recent(6)
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

  should 'find by initial' do
    person = create_user('testuser').person

    a1 = person.articles.create!(:name => 'An nice article')
    a2 = person.articles.create!(:name => 'Better stay off here')

    list = Article.find_by_initial('a')

    assert_includes list, a1
    assert_not_includes list, a2
  end

  should 'identify itself as a non-folder' do
    assert !Article.new.folder?, 'should identify itself as non-folder'
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

  should 'not display to other unauthenticated user if private' do
    # a person with private contents ...
    person = create_user('testuser').person
    person.update_attributes!(:public_content => false)

    # ... has an article ...
    a1 = person.articles.create!(:name => 'test article')

    # ... which anonymous users cannot view
    assert_equal false, a1.display_to?(nil)
  end

  should 'not display to another user if private' do
    # a person with private contents ...
    person = create_user('testuser').person
    person.update_attributes!(:public_content => false)

    # ... has an article ...
    a1 = person.articles.create!(:name => 'test article')

    # ... which another user cannot see
    another_user = create_user('another_user').person
    assert_equal false, a1.display_to?(another_user)
  end

  should 'display for members of profile' do
    # a community with private content ...
    community = Community.create!(:name => 'test community')
    community.update_attributes!(:public_content => false)

    # ... has an article ...
    a1 = community.articles.create!(:name => 'test article')

    # ... and its members ...
    member = create_user('testuser').person
    community.add_member(member)

    # ... can view that article
    assert_equal true, a1.display_to?(member)
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
    c1 = Category.create!(:environment => Environment.default, :name => 'c1')
    c2 = Category.create!(:environment => Environment.default, :name => 'c2')

    p = create_user('testinguser').person
    a = p.articles.create!(:name => 'test', :category_ids => [c1.id, c2.id])

    assert_equivalent [c1, c2], a.categories(true)

  end

  should 'not accept Product category as category' do
    assert !Article.new.accept_category?(ProductCategory.new)
  end

end
