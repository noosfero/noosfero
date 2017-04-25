require_relative '../test_helper'

class TinyMceArticleTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
    @profile = create_user('testing').person
  end

  attr_accessor :environment, :profile

  should 'be found when searching for articles by query' do
    TestSolr.enable
    tma = TextArticle.create!(:name => 'test tinymce article', :body => '---', :profile => profile)
    assert_includes TextArticle.find_by_contents('article')[:results], tma
    assert_includes Article.find_by_contents('article')[:results], tma
  end

  should 'define type facet' do
    a = TextArticle.new
    assert_equal TextArticle.type_name, TextArticle.send(:solr_plugin_f_type_proc, a.send(:solr_plugin_f_type))
  end
end
