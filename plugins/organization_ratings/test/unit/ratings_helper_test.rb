require File.expand_path(File.dirname(__FILE__)) + '/../../../../test/test_helper'
require 'ratings_helper'

class RatingsHelperTest < ActiveSupport::TestCase
  include RatingsHelper
  include ActionView::Helpers::TagHelper

  def setup

    @environment = Environment.default
    @environment.enabled_plugins = ['OrganizationRatingsPlugin']
    @environment.save
    @person = create_user('testuser').person
    @community = Community.create(:name => "TestCommunity")
    @organization_ratings_config = OrganizationRatingsConfig.instance
    @rating = fast_create(OrganizationRating, {:value => 1,
                                               :person_id => @person.id,
                                               :organization_id => @community.id,
                                               :created_at => DateTime.now,
                                               :updated_at => DateTime.now,
                                              })
  end

  should "get the ratings of a community ordered by most recent ratings" do
    ratings_array = []

    first_rating = OrganizationRating.new
    first_rating.organization = @community
    first_rating.person = @person
    first_rating.value = 3
    first_rating.save

    most_recent_rating = OrganizationRating.new
    most_recent_rating.organization = @community
    most_recent_rating.person = @person
    most_recent_rating.value = 5
    sleep 2
    most_recent_rating.save

    ratings_array << most_recent_rating
    ratings_array << first_rating
    ratings_array << @rating

    assert_equal @organization_ratings_config.order, "recent"
    assert_equal ratings_array, get_ratings(@community.id)
  end

  should "get the ratings of a community ordered by best ratings" do
    ratings_array = []
    @organization_ratings_config = "best"
    @environment.save

    first_rating = OrganizationRating.new
    first_rating.organization = @community
    first_rating.person = @person
    first_rating.value = 3
    first_rating.save

    second_rating = OrganizationRating.new
    second_rating.organization = @community
    second_rating.person = @person
    second_rating.value = 5
    sleep 2
    second_rating.save

    ratings_array << second_rating
    ratings_array << first_rating
    ratings_array << @rating

    assert_equal ratings_array, get_ratings(@community.id)
  end

  test "display report moderation message to community admin" do
    @moderator = create_user('moderator').person
    @community.add_admin(@moderator)
    @rating.stubs(:task_status).returns(Task::Status::ACTIVE)
    assert status_message_for(@moderator, @rating).include?("Report waiting for approval")
  end

  test "display report moderation message to owner" do
    @rating.stubs(:task_status).returns(Task::Status::ACTIVE)
    assert status_message_for(@person, @rating).include?("Report waiting for approval")
  end

  test "display report rejected message to owner" do
    @rating.stubs(:task_status).returns(Task::Status::CANCELLED)
    assert status_message_for(@person, @rating).include?("Report rejected")
  end

  test "do not display report moderation message to regular user" do
    @regular_person = fast_create(Person)
    @rating.stubs(:task_status).returns(Task::Status::ACTIVE)
    assert_nil status_message_for(@regular_person, @rating)
  end

  test "return empty status message to not logged user" do
    @rating.stubs(:task_status).returns(Task::Status::ACTIVE)
    assert_nil status_message_for(nil, @rating)
  end

  test "do not display status message if report task is finished" do
    @rating.stubs(:task_status).returns(Task::Status::FINISHED)
    assert_nil status_message_for(@person, @rating)
  end

end
