require File.dirname(__FILE__) + '/../test_helper'

class PublishedArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('test_user').person
    @article = @profile.articles.create!(:name => 'test_article', :body => 'some trivial body')
  end
  
  
  should 'have a reference article and profile' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create(:reference_article => @article, :profile => prof)

    assert p
    assert_equal prof, p.profile
    assert_equal @article, p.reference_article
  end

  should 'have same content as reference article' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create(:reference_article => @article, :profile => prof)

    assert_equal @article.body, p.body
  end

  should 'have a different name than reference article' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create(:reference_article => @article, :profile => prof, :name => 'other title')

    assert_equal 'other title', p.name
    assert_not_equal @article.name, p.name
    
  end

  should 'use name of reference article a default name' do
    prof = Community.create!(:name => 'test_comm', :identifier => 'test_comm')
    p = PublishedArticle.create!(:reference_article => @article, :profile => prof)

    assert_equal @article.name, p.name
  end
end
