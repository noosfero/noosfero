require 'test_helper'

class TextileArticleTest < ActiveSupport::TestCase
  
  should 'define type facet' do
	  a = TextileArticle.new
		assert_equal TextArticle.type_name, TextileArticle.send(:f_type_proc, a.send(:f_type))
  end

end
