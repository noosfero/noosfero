require "#{File.dirname(__FILE__)}/../test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'reindex articles after saving' do
    cat = Category.create!(:name => 'category 1', :environment_id => environment.id)
    art = Article.create!(:name => 'something', :profile_id => fast_create(Person).id)
    art.add_category cat
    cat.reload

    solr_doc = art.to_solr_doc
    Article.any_instance.expects(:to_solr_doc).returns(solr_doc)
    cat.save!
  end

  should 'act as searchable' do
    TestSolr.enable
    parent = fast_create(Category, :name => 'books')
    c = Category.create!(:name => "science fiction", :acronym => "sf", :abbreviation => "sci-fi",
                         :environment_id => environment.id, :parent_id => parent.id)

    # fields
    assert_includes Category.find_by_contents('fiction')[:results].docs, c
    assert_includes Category.find_by_contents('sf')[:results].docs, c
    assert_includes Category.find_by_contents('sci-fi')[:results].docs, c
    # filters
    assert_includes Category.find_by_contents('science', {}, {
      :filter_queries => ["parent_id:#{parent.id}"]})[:results].docs, c
  end

  should 'boost name matches' do
    TestSolr.enable
    c_abbr = Category.create!(:name => "something else", :abbreviation => "science", :environment_id => environment.id)
    c_name = Category.create!(:name => "science fiction", :environment_id => environment.id)
    assert_equal [c_name, c_abbr], Category.find_by_contents("science")[:results].docs
  end

  should 'solr save' do
    c = environment.categories.build(:name => 'my category');
    c.expects(:solr_save)
    c.save!
  end
end
