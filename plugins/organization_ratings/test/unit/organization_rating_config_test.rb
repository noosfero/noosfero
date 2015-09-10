require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'

class OrganizationRatingConfigTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @environment.enabled_plugins = ['OrganizationRatingsPlugin']
    @environment.save
    @organization_ratings_config = OrganizationRatingsConfig.instance
  end

  test "Community ratings config default rating validation" do
    @organization_ratings_config.default_rating = 0
    @organization_ratings_config.save

    assert_equal false, @organization_ratings_config.valid?
    assert_equal "must be greater than or equal to 1", @organization_ratings_config.errors[:default_rating].first

    @organization_ratings_config.default_rating = 6
    assert_equal false, @organization_ratings_config.valid?

    assert_equal "must be less than or equal to 5", @organization_ratings_config.errors[:default_rating].first
  end

  test "Communities ratings config cooldown validation" do
    @organization_ratings_config.cooldown = -1
    assert_equal false, @organization_ratings_config.valid?

    assert_equal "must be greater than or equal to 0", @organization_ratings_config.errors[:cooldown].first
  end

  # test "communities ratings per page validation" do
  #   environment = Environment.new :communities_ratings_per_page => 4
  #   environment.valid?

  #   assert_equal "must be greater than or equal to 5", environment.errors[:communities_ratings_per_page].first

  #   environment.communities_ratings_per_page = 21
  #   environment.valid?

  #   assert_equal "must be less than or equal to 20", environment.errors[:communities_ratings_per_page].first
  # end
end
