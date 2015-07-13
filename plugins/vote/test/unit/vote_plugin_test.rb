require 'test_helper'

class VotePluginTest < ActiveSupport::TestCase

  def setup
    @plugin = VotePlugin.new
    @person = create_user('user').person
    @article = TinyMceArticle.create!(:profile => @person, :name => 'An article')
    @comment = Comment.create!(:source => @article, :author => @person, :body => 'test')
  end

  attr_reader :plugin, :comment, :article

  should 'have a stylesheet' do
    assert plugin.stylesheet?
  end

  should 'have a javascript' do
    assert plugin.js_files
  end

  should 'return proc to display partials to vote for comments' do
    assert plugin.comment_actions(comment).kind_of?(Proc)
  end

  should 'return proc to display partials to vote for articles' do
    assert plugin.article_header_extra_contents(article).kind_of?(Proc)
  end

end
