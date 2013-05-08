require "#{File.dirname(__FILE__)}/../test_helper"

class ArticleTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
    @profile = create_user('testing').person
  end

  attr_accessor :environment, :profile

  should 'act as faceted' do
    person = fast_create(Person)
    cat = Category.create!(:name => 'hardcore', :environment_id => Environment.default.id)
    a = Article.create!(:name => 'black flag review', :profile_id => person.id)
    a.add_category(cat, true)
    a.save!
    assert_equal Article.type_name, Article.facet_by_id(:solr_plugin_f_type)[:proc].call(a.send(:solr_plugin_f_type))
    assert_equal Person.type_name, Article.facet_by_id(:solr_plugin_f_profile_type)[:proc].call(a.send(:solr_plugin_f_profile_type))
    assert_equal a.published_at, a.send(:solr_plugin_f_published_at)
    assert_equal ['hardcore'], a.send(:solr_plugin_f_category)
    assert_equal "solr_plugin_category_filter:\"#{cat.id}\"", Article.facet_category_query.call(cat)
  end

  should 'act as searchable' do
    TestSolr.enable
    person = fast_create(Person, :name => "Hiro", :address => 'U-Stor-It @ Inglewood, California',
                         :nickname => 'Protagonist')
    person2 = fast_create(Person, :name => "Raven")
    category = fast_create(Category, :name => "science fiction", :acronym => "sf", :abbreviation => "sci-fi")
    a = Article.create!(:name => 'a searchable article about bananas', :profile_id => person.id,
                        :body => 'the body talks about mosquitos', :abstract => 'and the abstract is about beer',
                        :filename => 'not_a_virus.exe')
    a.add_category(category)
    c = a.comments.build(:title => 'snow crash', :author => person2, :body => 'wanna try some?')
    c.save!

    # fields
    assert_includes Article.find_by_contents('bananas')[:results].docs, a
    assert_includes Article.find_by_contents('mosquitos')[:results].docs, a
    assert_includes Article.find_by_contents('beer')[:results].docs, a
    assert_includes Article.find_by_contents('not_a_virus.exe')[:results].docs, a
    # filters
    assert_includes Article.find_by_contents('bananas', {}, {:filter_queries => ["solr_plugin_public:true"]})[:results].docs, a
    assert_not_includes Article.find_by_contents('bananas', {}, {:filter_queries => ["solr_plugin_public:false"]})[:results].docs, a
    assert_includes Article.find_by_contents('bananas', {}, {:filter_queries => ["environment_id:\"#{Environment.default.id}\""]})[:results].docs, a
    assert_includes Article.find_by_contents('bananas', {}, {:filter_queries => ["profile_id:\"#{person.id}\""]})[:results].docs, a
    # includes
    assert_includes Article.find_by_contents('Hiro')[:results].docs, a
    assert_includes Article.find_by_contents("person-#{person.id}")[:results].docs, a
    assert_includes Article.find_by_contents("California")[:results].docs, a
    assert_includes Article.find_by_contents("Protagonist")[:results].docs, a
# FIXME: After merging with AI1826, searching on comments is not working
#    assert_includes Article.find_by_contents("snow")[:results].docs, a
#    assert_includes Article.find_by_contents("try some")[:results].docs, a
#    assert_includes Article.find_by_contents("Raven")[:results].docs, a
#
# FIXME: After merging with AI1826, searching on categories is not working
#    assert_includes Article.find_by_contents("science")[:results].docs, a
#    assert_includes Article.find_by_contents(category.slug)[:results].docs, a
#    assert_includes Article.find_by_contents("sf")[:results].docs, a
#    assert_includes Article.find_by_contents("sci-fi")[:results].docs, a
  end

  should 'boost name matches' do
    TestSolr.enable
    person = fast_create(Person)
    in_body = Article.create!(:name => 'something', :profile_id => person.id, :body => 'bananas in the body!')
    in_name = Article.create!(:name => 'bananas in the name!', :profile_id => person.id)
    assert_equal [in_name, in_body], Article.find_by_contents('bananas')[:results].docs
  end

  should 'boost if profile is enabled' do
    TestSolr.enable
    person2 = fast_create(Person, :enabled => false)
    art_profile_disabled = Article.create!(:name => 'profile disabled', :profile_id => person2.id)
    person1 = fast_create(Person, :enabled => true)
    art_profile_enabled = Article.create!(:name => 'profile enabled', :profile_id => person1.id)
    assert_equal [art_profile_enabled, art_profile_disabled], Article.find_by_contents('profile')[:results].docs
  end

  should 'index comments body together with article' do
    TestSolr.enable
    owner = create_user('testuser').person
    art = fast_create(TinyMceArticle, :profile_id => owner.id, :name => 'ytest')
    c1 = Comment.create!(:title => 'test comment', :body => 'anything', :author => owner, :source => art)

    assert_includes Article.find_by_contents('anything')[:results], art
  end

  should 'index by schema name when database is postgresql' do
    TestSolr.enable
    uses_postgresql 'schema_one'
    art1 = Article.create!(:name => 'some thing', :profile_id => @profile.id)
    assert_equal [art1], Article.find_by_contents('thing')[:results].docs
    uses_postgresql 'schema_two'
    art2 = Article.create!(:name => 'another thing', :profile_id => @profile.id)
    assert_not_includes Article.find_by_contents('thing')[:results], art1
    assert_includes Article.find_by_contents('thing')[:results], art2
    uses_postgresql 'schema_one'
    assert_includes Article.find_by_contents('thing')[:results], art1
    assert_not_includes Article.find_by_contents('thing')[:results], art2
    uses_sqlite
  end

  should 'not index by schema name when database is not postgresql' do
    TestSolr.enable
    uses_sqlite
    art1 = Article.create!(:name => 'some thing', :profile_id => @profile.id)
    assert_equal [art1], Article.find_by_contents('thing')[:results].docs
    art2 = Article.create!(:name => 'another thing', :profile_id => @profile.id)
    assert_includes Article.find_by_contents('thing')[:results], art1
    assert_includes Article.find_by_contents('thing')[:results], art2
  end
end
