require "#{File.dirname(__FILE__)}/../test_helper"

class ProfileTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex articles after saving' do
    profile = create(Person, :name => 'something', :user_id => fast_create(User).id)
    art = profile.articles.build(:name => 'something')
    Profile.expects(:solr_batch_add).with(includes(art))
    profile.save!
  end

  should 'act as faceted' do
    st = fast_create(State, :acronym => 'XZ')
    city = fast_create(City, :name => 'Tabajara', :parent_id => st.id)
    cat = fast_create(Category)
    prof = fast_create(Person, :region_id => city.id)
    prof.add_category(cat, true)
    assert_equal ['Tabajara', ', XZ'], Profile.facet_by_id(:solr_plugin_f_region)[:proc].call(prof.send(:solr_plugin_f_region))
    assert_equal "solr_plugin_category_filter:#{cat.id}", Person.facet_category_query.call(cat)
  end

  should 'act as searchable' do
    TestSolr.enable
    st = create(State, :name => 'California', :acronym => 'CA', :environment_id => Environment.default.id)
    city = create(City, :name => 'Inglewood', :parent_id => st.id, :environment_id => Environment.default.id)
    p = create(Person, :name => "Hiro", :address => 'U-Stor-It', :nickname => 'Protagonist',
               :user_id => fast_create(User).id, :region_id => city.id)
    cat = create(Category, :name => "Science Fiction", :acronym => "sf", :abbreviation => "sci-fi")
    p.add_category cat

    # fields
    assert_includes Profile.find_by_contents('Hiro')[:results].docs, p
    assert_includes Profile.find_by_contents('Protagonist')[:results].docs, p
    # filters
    assert_includes Profile.find_by_contents('Hiro', {}, { :filter_queries => ["solr_plugin_public:true"]})[:results].docs, p
    assert_not_includes Profile.find_by_contents('Hiro', {}, { :filter_queries => ["solr_plugin_public:false"]})[:results].docs, p
    assert_includes Profile.find_by_contents('Hiro', {}, { :filter_queries => ["environment_id:\"#{Environment.default.id}\""]})[:results].docs, p
    # includes
    assert_includes Profile.find_by_contents("Inglewood")[:results].docs, p
    assert_includes Profile.find_by_contents("California")[:results].docs, p
    assert_includes Profile.find_by_contents("Science")[:results].docs, p
    # not includes
    assert_not_includes Profile.find_by_contents('Stor')[:results].docs, p
  end

  should 'boost name matches' do
    TestSolr.enable
    in_addr = create(Person, :name => 'something', :address => 'bananas in the address!', :user_id => fast_create(User).id)
    in_name = create(Person, :name => 'bananas in the name!', :user_id => fast_create(User).id)
    assert_equal [in_name], Person.find_by_contents('bananas')[:results].docs
  end

  should 'be able to add extra data for index' do
    klass = Class.new(Profile)
    klass.any_instance.expects(:random_method)
    klass.solr_plugin_extra_data_for_index :random_method

    klass.new.solr_plugin_extra_data_for_index
  end

  should 'be able to add a block as extra data for index' do
    klass = Class.new(Profile)
    result = Object.new
    klass.solr_plugin_extra_data_for_index do |obj|
      result
    end

    assert_includes klass.new.solr_plugin_extra_data_for_index, result
  end

  should 'actually index by results of solr_plugin_extra_data_for_index' do
    TestSolr.enable
    class ExtraDataForIndex < Profile
      solr_plugin_extra_data_for_index do |obj|
        'sample indexed text'
      end
    end
    profile = ExtraDataForIndex.create!(:name => 'testprofile', :identifier => 'testprofile')

    assert_includes ExtraDataForIndex.find_by_contents('sample')[:results], profile
  end

  should 'find_by_contents' do
    TestSolr.enable
    p = create(Profile, :name => 'wanted')

    assert Profile.find_by_contents('wanted')[:results].include?(p)
    assert ! Profile.find_by_contents('not_wanted')[:results].include?(p)
  end

  # This problem should be solved; talk to Bráulio if it fails
  should 'be able to find profiles by their names' do
    TestSolr.enable
    small = create(Profile, :name => 'A small profile for testing')
    big = create(Profile, :name => 'A big profile for testing')

    assert Profile.find_by_contents('small')[:results].include?(small)
    assert Profile.find_by_contents('big')[:results].include?(big)

    both = Profile.find_by_contents('profile testing')[:results]
    assert both.include?(small)
    assert both.include?(big)
  end

  should 'search with latitude and longitude' do
    TestSolr.enable
    e = fast_create(Enterprise, {:lat => 45, :lng => 45}, :search => true)

    assert_includes Enterprise.find_by_contents('', {}, {:radius => 2, :latitude => 45, :longitude => 45})[:results].docs, e
  end

  should 'index profile identifier for searching' do
    TestSolr.enable
    Profile.destroy_all
    p = create(Profile, :identifier => 'lalala')
    assert_includes Profile.find_by_contents('lalala')[:results], p
  end

  should 'index profile name for searching' do
    TestSolr.enable
    p = create(Profile, :name => 'Interesting Profile')
    assert_includes Profile.find_by_contents('interesting')[:results], p
  end

  should 'index comments title together with article' do
    TestSolr.enable
    owner = create_user('testuser').person
    art = fast_create(TinyMceArticle, :profile_id => owner.id, :name => 'ytest')
    c1 = Comment.create(:title => 'a nice comment', :body => 'anything', :author => owner, :source => art ); c1.save!

    assert_includes Article.find_by_contents('nice')[:results], art
  end

  should 'index by schema name when database is postgresql' do
    TestSolr.enable
    uses_postgresql 'schema_one'
    p1 = Profile.create!(:name => 'some thing', :identifier => 'some-thing')
    assert_equal [p1], Profile.find_by_contents('thing')[:results].docs
    uses_postgresql 'schema_two'
    p2 = Profile.create!(:name => 'another thing', :identifier => 'another-thing')
    assert_not_includes Profile.find_by_contents('thing')[:results], p1
    assert_includes Profile.find_by_contents('thing')[:results], p2
    uses_postgresql 'schema_one'
    assert_includes Profile.find_by_contents('thing')[:results], p1
    assert_not_includes Profile.find_by_contents('thing')[:results], p2
    uses_sqlite
  end

  should 'not index by schema name when database is not postgresql' do
    TestSolr.enable
    uses_sqlite
    p1 = Profile.create!(:name => 'some thing', :identifier => 'some-thing')
    assert_equal [p1], Profile.find_by_contents('thing')[:results].docs
    p2 = Profile.create!(:name => 'another thing', :identifier => 'another-thing')
    assert_includes Profile.find_by_contents('thing')[:results], p1
    assert_includes Profile.find_by_contents('thing')[:results], p2
  end
end
