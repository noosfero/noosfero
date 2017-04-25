require_relative '../test_helper'

class TextArticleTest < ActiveSupport::TestCase
  def setup
    @environment = Environment.default
    @environment.enable_plugin(SolrPlugin)
  end

  attr_accessor :environment

  should 'found TextArticle by TextArticle indexes' do
    TestSolr.enable
    person = create_user('testuser').person
    article = TextArticle.create!(:name => 'found article test', :profile => person)
    assert_equal TextArticle.find_by_contents('found')[:results].docs, TextArticle.find_by_contents('found')[:results].docs
  end
end
