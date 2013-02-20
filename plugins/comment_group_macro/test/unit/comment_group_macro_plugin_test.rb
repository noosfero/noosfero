require File.dirname(__FILE__) + '/../../../../test/test_helper'

class CommentGroupMacroPluginTest < ActiveSupport::TestCase

  include Noosfero::Plugin::HotSpot

  def setup
    @environment = Environment.default
  end
 
  attr_reader :environment

  should 'register comment_group_macro in environment' do
    Environment.macros = {}
    Environment.macros[environment.id] = {}
    macros = Environment.macros[environment.id]
    context = mock()
    context.stubs(:environment).returns(environment)
    plugin = CommentGroupMacroPlugin.new(context)
    assert_equal ['macro_display_comments'], macros.keys
  end

  should 'load_comments returns all the comments wihout group of an article passed as parameter' do
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
    c2 = fast_create(Comment, :source_id => article.id)
    c3 = fast_create(Comment, :source_id => article.id)

    plugin = CommentGroupMacroPlugin.new
    assert_equal [], [c2, c3] - plugin.load_comments(article)
    assert_equal [], plugin.load_comments(article) - [c2, c3]
  end
 
  should 'load_comments not returns spam comments' do
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
    c2 = fast_create(Comment, :source_id => article.id)
    c3 = fast_create(Comment, :source_id => article.id, :spam => true)

    plugin = CommentGroupMacroPlugin.new
    assert_equal [], [c2] - plugin.load_comments(article)
    assert_equal [], plugin.load_comments(article) - [c2]
  end
 
  should 'load_comments returns only root comments of article' do
    article = fast_create(Article)
    c1 = fast_create(Comment, :source_id => article.id, :group_id => 1)
    c2 = fast_create(Comment, :source_id => article.id)
    c3 = fast_create(Comment, :source_id => article.id, :reply_of_id => c2.id)

    plugin = CommentGroupMacroPlugin.new
    assert_equal [], [c2] - plugin.load_comments(article)
    assert_equal [], plugin.load_comments(article) - [c2]
  end

  should 'params of macro display comments configuration be an empty array' do
    plugin = CommentGroupMacroPlugin.new
    assert_equal [], plugin.config_macro_display_comments[:params]
  end

  should 'skip_dialog of macro display comments configuration be true' do
    plugin = CommentGroupMacroPlugin.new
    assert plugin.config_macro_display_comments[:skip_dialog]
  end

  should 'generator of macro display comments configuration be the makeCommentable function' do
    plugin = CommentGroupMacroPlugin.new
    assert_equal 'makeCommentable();', plugin.config_macro_display_comments[:generator]
  end
 
  should 'js_files of macro display comments configuration return comment_group.js' do
    plugin = CommentGroupMacroPlugin.new
    assert_equal 'comment_group.js', plugin.config_macro_display_comments[:js_files]
  end
  
  should 'css_files of macro display comments configuration return comment_group.css' do
    plugin = CommentGroupMacroPlugin.new
    assert_equal 'comment_group.css', plugin.config_macro_display_comments[:css_files]
  end
 
end
