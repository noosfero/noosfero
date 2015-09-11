require_relative "../test_helper"

class CloneArticleTest < ActiveSupport::TestCase

  should 'cloned article have its source attributes' do
    community = fast_create(Community)
    folder = fast_create(Folder, :profile_id => community.id)
    article = fast_create(TinyMceArticle, :profile_id => community.id)
    article.parent_id = folder.id
    article.save!

    article.reload
    cloned_article = article.copy_without_save({:parent_id => article.parent_id})

    assert_equal folder.id, cloned_article.parent_id
    assert_equal article.body , cloned_article.body
    assert_equal article.name, cloned_article.name
    assert_equal article.setting, cloned_article.setting
  end

end