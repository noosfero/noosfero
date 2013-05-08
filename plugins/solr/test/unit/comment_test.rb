require "#{File.dirname(__FILE__)}/../test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'notify article to reindex after saving' do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')

    article.expects(:solr_plugin_comments_updated)

    c1 = article.comments.new(:title => "A comment", :body => '...', :author => owner)
    c1.stubs(:article).returns(article)
    c1.save!
  end

  should 'notify article to reindex after being removed' do
    owner = create_user('testuser').person
    article = owner.articles.create!(:name => 'test', :body => '...')
    c1 = article.comments.create!(:title => "A comment", :body => '...', :author => owner)

    c1.stubs(:article).returns(article)
    article.expects(:solr_plugin_comments_updated)
    c1.destroy
  end
end

