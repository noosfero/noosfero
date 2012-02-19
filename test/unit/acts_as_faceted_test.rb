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
      'Blog' => "Blog",
      'Forum' => "Forum"
    }
    h[klass]
  end
  def self.f_profile_type_proc(klass)
    h = {
      'Enterprise' => "Enterprise", 
      'Community' => "Community",
      'Person' => "Person",
      'BscPlugin::Bsc' => "BSC"
    }
    h[klass]
  end
  acts_as_faceted :fields => {
    :f_type => {:label => 'Type', :proc => proc{|klass| f_type_proc(klass)}},
    :f_published_at => {:type => :date, :label => 'Published date', :queries => {'[* TO NOW-1YEARS/DAY]' => "Older than one year", '[NOW-1YEARS TO NOW/DAY]' => "Last year"}},
    :f_profile_type => {:label => 'Author', :proc => proc{|klass| f_profile_type_proc(klass)}},
    :f_category => {:label => 'Categories'}},
    :order => [:f_type, :f_published_at, :f_profile_type, :f_category]
end

class ActsAsFacetedTest < ActiveSupport::TestCase
  def setup
    @facets = {
      "facet_fields"=> {
        "f_profile_type_facet"=>{"Person"=>29},
        "f_type_facet"=>{"TextArticle"=>15, "Blog"=>3, "Folder"=>3, "Forum"=>1, "UploadedFile"=>6, "Gallery"=>1},
        "f_category_facet"=>{}},
      "facet_ranges"=>{}, "facet_dates"=>{},
      "facet_queries"=>{"f_published_at_d:[* TO NOW-1YEARS/DAY]"=>10, "f_published_at_d:[NOW-1YEARS TO NOW/DAY]"=>19}
    }
  end

  should 'iterate over each result' do
    f = TestModel.facet_by_id(:f_type)
    r = []
    TestModel.each_facet_result(f, @facets, {}) { |i| r.push i }
    assert_equal r, [["TextArticle", 'Text', 15], ["Blog", "Blog", 3], ["Folder", "Folder", 3], ["Forum", "Forum", 1], ["UploadedFile", "Uploaded File", 6], ["Gallery", "Gallery", 1]]

    f = TestModel.facet_by_id(:f_published_at)
    r = []
    TestModel.each_facet_result(f, @facets, {}) { |i| r.push i }
    assert_equal r, [ ["[* TO NOW-1YEARS/DAY]", "Older than one year", 10], ["[NOW-1YEARS TO NOW/DAY]", "Last year", 19] ]
  end

  should 'query label of a facet' do
    l = TestModel.facet_by_id(:f_type)
    assert_equal l[:label], 'Type'
    l = TestModel.facet_by_id(:f_published_at)
    assert_equal l[:queries]['[* TO NOW-1YEARS/DAY]'], 'Older than one year'
  end

  should 'return browse options hash in acts_as_solr format' do
    o = TestModel.facets_find_options()[:facets]
    assert_equal o[:browse], []

    o = TestModel.facets_find_options({'f_profile_type' => 'Person', 'f_published_at' => '[* TO NOW-1YEARS/DAY]'})[:facets]
    assert_equal o[:browse], ['f_profile_type:"Person"', 'f_published_at:[* TO NOW-1YEARS/DAY]']
  end

end
