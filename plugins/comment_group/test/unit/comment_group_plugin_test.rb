require File.dirname(__FILE__) + '/../../../../test/test_helper'

class CommentGroupPluginTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = Environment.default
  end

  attr_reader :environment

#FIXME Obsolete test
#
#  should 'filter_comments returns all the comments wihout group of an article passed as parameter' do
#    article = fast_create(Article)
#    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
#    c2 = fast_create(Comment, :source_id => article.id)
#    c3 = fast_create(Comment, :source_id => article.id)
#
#    plugin = CommentGroupPlugin.new
#    assert_equal [], [c2, c3] - plugin.filter_comments(article.comments)
#    assert_equal [], plugin.filter_comments(article.comments) - [c2, c3]
#  end

end
