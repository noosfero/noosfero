require "#{File.dirname(__FILE__)}/../test_helper"

class TextileArticleTest < ActiveSupport::TestCase

  should 'define type facet' do
	  a = TextileArticle.new
		assert_equal TextArticle.type_name, TextileArticle.send(:solr_plugin_f_type_proc, a.send(:solr_plugin_f_type))
  end

end
