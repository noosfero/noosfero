require 'test_helper'

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
end
