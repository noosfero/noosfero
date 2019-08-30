require "test_helper"

class ArticleHelperTest < ActionView::TestCase
  include ArticleHelper
  include ButtonsHelper

  should "render follow article button" do
    environment = Environment.default
    person =  fast_create(Person, identifier: "profile-6")
    profile = fast_create(Profile, environment_id: environment)
    article = fast_create(Article, profile_id: profile)
    link = following_button article, person
    assert_tag_in_string link, tag: "a", attributes: { "href" => /\/follow_article\?article_id=#{article.id}/ }
  end
end
