require File.dirname(__FILE__) + '/../test_helper'

class TestModel < ActiveRecord::Base
  def self.f_type_proc(klass)
    klass.constantize 
    h = {
      'UploadedFile' => "Uploaded File", 
      'TextArticle' => "Text",
      'Folder' => "Folder",
      'Event' => "Event",
      'EnterpriseHomepage' => "Homepage",
      'Gallery' => "Gallery",
    }
    h[klass]
  end
  acts_as_faceted :fields => {
      :f_type => {:label => 'Type', :proc => proc{|klass| f_type_proc(klass)}},
      :f_published_at => {:type => :date, :label => 'Published date', :queries =>
        {'[* TO NOW-1YEARS/DAY]' => "Older than one year", '[NOW-1YEARS TO NOW/DAY]' => "Last year"}},
    }, :order => [:f_type, :f_published_at]
end

class ActsAsFacetedTest < ActiveSupport::TestCase
  def setup
    @facets = {
      "facet_fields"=> {
        "f_type_facet"=>{"TextArticle"=>15, "Folder"=>3, "UploadedFile"=>6, "Gallery"=>1},
      }, "facet_ranges"=>{}, "facet_dates"=>{},
      "facet_queries"=>{"f_published_at_d:[* TO NOW-1YEARS/DAY]"=>10, "f_published_at_d:[NOW-1YEARS TO NOW/DAY]"=>19}
    }
    #any facet selected
    @facet_params = {}
    @all_facets = @facets
  end

  should 'get defined facets' do
    assert TestModel.facets.has_key? :f_type
    assert TestModel.facets.has_key? :f_published_at
  end

  should 'get facets by id' do
    facet = TestModel.facet_by_id :f_type
    assert_equal :f_type, facet[:id]
    assert_equal TestModel.facets[:f_type][:label], facet[:label]
    assert_equal TestModel.facets[:f_type][:proc], facet[:proc]
  end

  should 'convert facets to solr field names' do
    solr_names = TestModel.solr_fields_names
    assert solr_names.include?("f_type_facet")
    assert solr_names.include?("f_published_at_d")

    solr_names = TestModel.to_solr_fields_names

    assert_equal solr_names[:f_type], 'f_type_facet'
    assert_equal solr_names[:f_published_at], 'f_published_at_d'
  end

  should 'return facets containers' do
    containers = TestModel.facets_results_containers

    assert_equal containers.count, 3
    assert_equal containers[:fields], 'facet_fields'
    assert_equal containers[:queries], 'facet_queries'
    assert_equal containers[:ranges], 'facet_ranges'
  end

  should 'show facets option for solr' do
    assert TestModel.facets_option_for_solr.include?(:f_type)
    assert !TestModel.facets_option_for_solr.include?(:f_published_at)
  end

  should 'show facets fields for solr' do
    TestModel.facets_fields_for_solr.each do |facet|
      assert_equal facet[:f_type], :facet if facet[:f_type]
      assert_equal facet[:f_published_at], :date if facet[:f_published_at]
    end
  end

  should 'iterate over each result' do
    facets = TestModel.map_facets_for(Environment.default)
    assert facets.count, 2

    f = facets.select{ |f| f[:id] == 'f_type' }.first
    r = TestModel.map_facet_results f, @facet_params, @facets, @all_facets, {}
    assert_equivalent [["TextArticle", 'Text', 15], ["Folder", "Folder", 3], ["UploadedFile", "Uploaded File", 6], ["Gallery", "Gallery", 1]], r

    f = facets.select{ |f| f[:id] == 'f_published_at' }.first
    r = TestModel.map_facet_results f, @facet_params, @facets, @all_facets, {}
    assert_equivalent [["[* TO NOW-1YEARS/DAY]", "Older than one year", 10], ["[NOW-1YEARS TO NOW/DAY]", "Last year", 19]], r
  end

  should 'return facet hash in map_facets_for' do 
    r = TestModel.map_facets_for(Environment.default)
    assert r.count, 2

    f_type = r.select{ |f| f[:id] == 'f_type' }.first
    assert_equal f_type[:solr_field], :f_type
    assert_equal f_type[:label], "Type"

    f_published = r.select{ |f| f[:id] == 'f_published_at' }.first
    assert_equal :f_published_at, f_published[:solr_field]
    assert_equal :date, f_published[:type]
    assert_equal "Published date", f_published[:label]
    hash = {"[NOW-1YEARS TO NOW/DAY]"=>"Last year", "[* TO NOW-1YEARS/DAY]"=>"Older than one year"}
    assert_equal hash, f_published[:queries]
  end

  should 'get label of a facet' do
    f = TestModel.facet_by_id(:f_type)
    assert_equal f[:label], 'Type'
  end

  should "get facets' queries" do
    f = TestModel.facet_by_id(:f_published_at)
    assert_equal f[:queries]['[* TO NOW-1YEARS/DAY]'], 'Older than one year'
  end

  should 'not map_facet_results without map_facets_for' do
    assert_raise RuntimeError do
      f = TestModel.facet_by_id(:f_published_at)
      TestModel.map_facet_results f, @facet_params, @facets, @all_facets, {}
    end
  end

  should 'show correct ordering' do
    assert_equal TestModel.facets_order, [:f_type, :f_published_at]
  end

  should 'return facet options hash in acts_as_solr format' do
    options = TestModel.facets_find_options()[:facets]
    assert_equal [:f_type], options[:fields]
    assert_equivalent ["f_published_at:[NOW-1YEARS TO NOW/DAY]", "f_published_at:[* TO NOW-1YEARS/DAY]"], options[:query]
  end

  should 'return browse options hash in acts_as_solr format' do
    options = TestModel.facets_find_options()[:facets]
    assert_equal options[:browse], []

    options = TestModel.facets_find_options({'f_published_at' => '[* TO NOW-1YEARS/DAY]'})[:facets]
    assert_equal options[:browse], ['f_published_at:[* TO NOW-1YEARS/DAY]']
  end

  should 'sort facet results alphabetically' do
    facets = TestModel.map_facets_for(Environment.default)
    facet = facets.select{ |f| f[:id] == 'f_type' }.first
    facet_data = TestModel.map_facet_results facet, @facet_params, @facets, @all_facets, {}
    sorted = TestModel.facet_result_sort(facet, facet_data, :alphabetically) 
    assert_equal sorted,
      [["Folder", "Folder", 3], ["Gallery", "Gallery", 1], ["TextArticle", 'Text', 15], ["UploadedFile", "Uploaded File", 6]]
  end

  should 'sort facet results by count' do
    facets = TestModel.map_facets_for(Environment.default)
    facet = facets.select{ |f| f[:id] == 'f_type' }.first
    facet_data = TestModel.map_facet_results facet, @facet_params, @facets, @all_facets, {}
    sorted = TestModel.facet_result_sort(facet, facet_data, :count) 
    assert_equal sorted,
      [["TextArticle", "Text", 15], ["UploadedFile", "Uploaded File", 6], ["Folder", "Folder", 3], ["Gallery", "Gallery", 1]]
  end
end
