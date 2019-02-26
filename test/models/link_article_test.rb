require_relative '../test_helper'

class LinkArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('testing').person
    @article = fast_create(Article, :profile_id => profile.id, 
                name: 'some name', body: 'some content', abstract: 'some abstract', 
                author_id: @profile.id, created_by_id: @profile.id )
  end
  attr_reader :profile, :article

  ORIGINAL_ARTICLE_FIELDS = %w(name body abstract url author created_by)

  ORIGINAL_ARTICLE_FIELDS.map do |field|
    should "#{field} of article link redirects to referenced article" do
      link = LinkArticle.new(:reference_article => article)
      assert_equal article.send(field), link.send(field)
    end
  end

  should 'destroy link article when reference article is removed' do
    target_profile = fast_create(Community)
    article = fast_create(Article, :profile_id => profile.id)
    link = LinkArticle.create!(:reference_article => article, :profile => target_profile)
    article.destroy
    assert_raise ActiveRecord::RecordNotFound do
      link.reload
    end
  end

end
