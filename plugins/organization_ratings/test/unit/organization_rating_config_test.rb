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

  test "communities ratings per page validation" do
    @organization_ratings_config.per_page = 4

    refute @organization_ratings_config.valid?

    assert_equal "must be greater than or equal to 5", @organization_ratings_config.errors[:per_page].first

    @organization_ratings_config.per_page = 21
    refute @organization_ratings_config.valid?

    assert_equal "must be less than or equal to 20", @organization_ratings_config.errors[:per_page].first
  end

  should "ratings block use initial_page config" do
    @organization_ratings_config.ratings_on_initial_page = 4
    @organization_ratings_config.save!
    block = OrganizationRatingsBlock.new
    assert_equal block.ratings_on_initial_page, 4
  end

  should "ratings block show 3 ratings on initial page by default" do
    @organization_ratings_config.save!
    block = OrganizationRatingsBlock.new
    assert_equal block.ratings_on_initial_page, 3
  end
end
