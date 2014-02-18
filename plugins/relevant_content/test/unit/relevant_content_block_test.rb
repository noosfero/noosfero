require File.dirname(__FILE__) + '/../test_helper'

require 'comment_controller'
# Re-raise errors caught by the controller.
class CommentController; def rescue_action(e) raise e end; end

class RelevantContentBlockTest < ActiveSupport::TestCase
  
  include AuthenticatedTestHelper
  fixtures :users, :environments
  
  def setup
    @controller = CommentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @profile = create_user('testinguser').person
    @environment = @profile.environment
  end
  attr_reader :profile, :environment
  
  
 
  should 'have a default title' do
    relevant_content_block = RelevantContentPlugin::RelevantContentBlock.new
    block = Block.new
    assert_not_equal block.default_title, relevant_content_block.default_title
  end
  
  should 'have a help tooltip' do
    relevant_content_block = RelevantContentPlugin::RelevantContentBlock.new
    block = Block.new
    assert_not_equal "", relevant_content_block.help
  end

  should 'describe itself' do
    assert_not_equal Block.description, RelevantContentPlugin::RelevantContentBlock.description
  end
 
  should 'is editable' do
    block = RelevantContentPlugin::RelevantContentBlock.new
    assert block.editable?
  end

  should 'expire' do
    assert_equal RelevantContentPlugin::RelevantContentBlock.expire_on, {:environment=>[:article], :profile=>[:article]}
  end

  should 'not raise an exception when finding the most accessed content' do
    assert_nothing_raised{
      Article.most_accessed(Environment.default, 5)
    }
  end
  
  should 'not raise an exception when finding the most commented content' do
    assert_nothing_raised{
      Article.most_commented_relevant_content(Environment.default, 5)
    }
  end
 
  should 'not raise an exception when finding the most liked content' do
    begin 
      Environment.default.enable_plugin(:vote)
    rescue
      puts "Unable to activate vote plugin"      
    end  
    if Environment.default.plugin_enabled?(:vote)
      assert_nothing_raised{
        Article.most_liked(Environment.default, 5)
      }
    end
  end

  should 'not raise an exception when finding the most disliked content' do
    begin 
      Environment.default.enable_plugin(:vote)
    rescue
      puts "Unable to activate vote plugin"
    end  
    if Environment.default.plugin_enabled?(:vote)
      assert_nothing_raised{
        Article.most_disliked(Environment.default, 5)
      }
    end
  end

 
  should 'not raise an exception when finding the more positive votes' do
    begin 
      Environment.default.enable_plugin(:vote)
    rescue
      puts "Unable to activate vote plugin"      
    end  
    if Environment.default.plugin_enabled?(:vote)
      assert_nothing_raised{
        Article.more_positive_votes(Environment.default, 5)
      }
    end
  end

  should 'not raise an exception when finding the most voted' do
    begin 
      Environment.default.enable_plugin(:vote)
    rescue
      puts "Unable to activate vote plugin"
    end  
    if Environment.default.plugin_enabled?(:vote)
      assert_nothing_raised{
        Article.most_voted(Environment.default, 5)
      }
    end
  end
  
  should 'find the most voted' do

    article = fast_create(Article, {:name=>'2 votes'})
    for i in 0..2
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    article = fast_create(Article, {:name=>'10 votes'})
    for i in 0..10
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    article = fast_create(Article, {:name=>'5 votes'})
    for i in 0..5
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    articles = Article.most_voted(Environment.default, 5)
    assert_equal '10 votes', articles.first.name
    assert_equal '2 votes', articles.last.name
  end

  should 'list the most postive' do

    article = fast_create(Article, {:name=>'23 votes for 20 votes against'})
    for i in 0..20
        person = fast_create(Person)
        person.vote_against(article)
    end
    for i in 0..23
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    article = fast_create(Article, {:name=>'10 votes for 5 votes against'})
    for i in 0..10
        person = fast_create(Person)
        person.vote_for(article)
    end
    for i in 0..5
        person = fast_create(Person)
        person.vote_against(article)
    end
    
    article = fast_create(Article, {:name=>'2 votes against'})
    for i in 0..2
        person = fast_create(Person)
        person.vote_against(article)
    end

    article = fast_create(Article, {:name=>'7 votes for'})
    for i in 0..7
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    articles = Article.more_positive_votes(Environment.default, 5)
    assert_equal '7 votes for', articles.first.name
    assert_equal '23 votes for 20 votes against', articles.last.name
  end
  
  should 'list the most negative' do

    article = fast_create(Article, {:name=>'23 votes for 29 votes against'})
    for i in 0..29
        person = fast_create(Person)
        person.vote_against(article)
    end
    for i in 0..23
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    article = fast_create(Article, {:name=>'10 votes for 15 votes against'})
    for i in 0..10
        person = fast_create(Person)
        person.vote_for(article)
    end
    for i in 0..15
        person = fast_create(Person)
        person.vote_against(article)
    end
    
    article = fast_create(Article, {:name=>'2 votes against'})
    for i in 0..2
        person = fast_create(Person)
        person.vote_against(article)
    end

    article = fast_create(Article, {:name=>'7 votes for'})
    for i in 0..7
        person = fast_create(Person)
        person.vote_for(article)
    end
    
    articles = Article.more_negative_votes(Environment.default, 5)
    assert_equal '23 votes for 29 votes against', articles.first.name
    assert_equal '2 votes against', articles.last.name
  end
  
end
