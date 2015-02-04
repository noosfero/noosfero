require_relative "../test_helper"

class RawHTMLArticleTest < ActiveSupport::TestCase

  def setup
    @profile = create_user('testing').person
  end

  should 'not filter HTML' do
    article = RawHTMLArticle.create!(
      :name => 'Raw HTML',
      :body => '<strong>HTML!</strong><form action="#"></form>',
      :profile => @profile
    )
    assert_equal '<strong>HTML!</strong><form action="#"></form>', article.body
  end

end
