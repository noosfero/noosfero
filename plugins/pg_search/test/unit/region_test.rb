require_relative '../../../../test/test_helper'

class RegionTest < ActiveSupport::TestCase

  should 'return facets for articles' do
    profile = fast_create(Profile)
    region = fast_create(Region)
    region2 = fast_create(Region)

    profile.add_category(region)
    assert_equivalent [region],
                      Region.pg_search_plugin_profiles_facets(Profile.all)
  end

  should 'return facets for profiles' do
    article = fast_create(Article)
    region = fast_create(Region)
    region2 = fast_create(Region)

    article.add_category(region)
    assert_equivalent [region],
                      Region.pg_search_plugin_articles_facets(Article.all)
  end
end
