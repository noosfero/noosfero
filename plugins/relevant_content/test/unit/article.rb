require_relative '../test_helper'
require 'comment_controller'

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

  def enable_vote_plugin
    enabled = false
    environment = Environment.default
    if Noosfero::Plugin.all.include?('VotePlugin')
      if not environment.enabled_plugins.include?('VotePlugin')
        environment.enable_plugin(VotePlugin)
        environment.save!
      end
      enabled = true
    end
    enabled
  end

 should 'list most commented articles' do
    Article.delete_all
    a1 = create(TextileArticle, :name => "art 1", :profile_id => profile.id)
    a2 = create(TextileArticle, :name => "art 2", :profile_id => profile.id)
    a3 = create(TextileArticle, :name => "art 3", :profile_id => profile.id)

    2.times { Comment.create(:title => 'test', :body => 'asdsad', :author => profile, :source => a2).save! }
    4.times { Comment.create(:title => 'test', :body => 'asdsad', :author => profile, :source => a3).save! }

    # should respect the order (more commented comes first)
    assert_equal a3.name, profile.articles.most_commented_relevant_content(Environment.default, 3).first.name
    # It is a2 instead of a1 since it does not list articles without comments
    assert_equal a2.name, profile.articles.most_commented_relevant_content(Environment.default, 3).last.name
  end


  should 'find the most voted' do
    if not enable_vote_plugin
      return
    end
    article = fast_create(Article, {:name=>'2 votes'})
    2.times{
      person = fast_create(Person)
      person.vote_for(article)
    }
    article = fast_create(Article, {:name=>'10 votes'})
    10.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    article = fast_create(Article, {:name=>'5 votes'})
    5.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    articles = Article.most_voted(Environment.default, 5)
    assert_equal '10 votes', articles.first.name
    assert_equal '2 votes', articles.last.name
  end

  should 'list the most postive' do
    if not enable_vote_plugin
      return
    end
    article = fast_create(Article, {:name=>'23 votes for 20 votes against'})
    20.times{
        person = fast_create(Person)
        person.vote_against(article)
    }
    23.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    article = fast_create(Article, {:name=>'10 votes for 5 votes against'})
    10.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    5.times{
        person = fast_create(Person)
        person.vote_against(article)
    }
    article = fast_create(Article, {:name=>'2 votes against'})
    2.times{
        person = fast_create(Person)
        person.vote_against(article)
    }

    article = fast_create(Article, {:name=>'7 votes for'})
    7.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    articles = Article.more_positive_votes(Environment.default, 5)
    assert_equal '7 votes for', articles.first.name
    assert_equal '23 votes for 20 votes against', articles.last.name
  end

  should 'list the most negative' do
    if not enable_vote_plugin
      return
    end
    article = fast_create(Article, {:name=>'23 votes for 29 votes against'})
    29.times{
        person = fast_create(Person)
        person.vote_against(article)
    }
    23.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    article = fast_create(Article, {:name=>'10 votes for 15 votes against'})
    10.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    15.times{
        person = fast_create(Person)
        person.vote_against(article)
    }
    article = fast_create(Article, {:name=>'2 votes against'})
    2.times{
        person = fast_create(Person)
        person.vote_against(article)
    }
    article = fast_create(Article, {:name=>'7 votes for'})
    7.times{
        person = fast_create(Person)
        person.vote_for(article)
    }
    articles = Article.more_negative_votes(Environment.default, 5)
    assert_equal '23 votes for 29 votes against', articles.first.name
    assert_equal '2 votes against', articles.last.name
  end
end
