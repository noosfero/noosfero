require 'test_helper'
class OrganizationRatingTest < ActiveSupport::TestCase

  def setup
    @person = create_user('Mario').person
    @person.email = "person@email.com"
    @person.save
    @community = fast_create(Community)
    @adminuser = Person[create_admin_user(Environment.default)]
    @rating = fast_create(OrganizationRating, {:value => 1,
                                               :person_id => @person.id,
                                               :organization_id => @community.id,
                                               :created_at => DateTime.now,
                                               :updated_at => DateTime.now,
                                              })
  end

  test "The value must be between 1 and 5" do
    organization_rating1 = OrganizationRating.new :value => -1
    organization_rating2 = OrganizationRating.new :value => 6

    assert_equal false, organization_rating1.valid?
    assert_equal false, organization_rating2.valid?

    assert_equal true, organization_rating1.errors[:value].include?("must be between 1 and 5")
    assert_equal true, organization_rating2.errors[:value].include?("must be between 1 and 5")

    organization_rating1.value = 1
    organization_rating1.valid?

    organization_rating2.value = 5
    organization_rating2.valid?

    assert_equal false, organization_rating1.errors[:value].include?("must be between 1 and 5")
    assert_equal false, organization_rating2.errors[:value].include?("must be between 1 and 5")
  end

  test "false return when no active tasks for an Organization Rating" do
    assert_not @rating.task_active?
  end

  test "true return when an active task exists for an Organization Rating" do
    CreateOrganizationRatingComment.create!(
                      :organization_rating_id => @rating.id,
                      :target => @community,
                      :requestor => @person)

    assert_equal Task::Status::ACTIVE, CreateOrganizationRatingComment.last.status
    assert @rating.task_active?
  end

  test "return false when an cancelled task exists for an Organization Rating" do
    CreateOrganizationRatingComment.create!(
                      :organization_rating_id => @rating.id,
                      :target => @community,
                      :requestor => @person)
    CreateOrganizationRatingComment.last.cancel
    assert_not @rating.task_active?
  end

  test "display report moderation message to community admin" do
    moderator = create_user('moderator')
    @community.add_admin(moderator.person)
    @rating.stubs(:task_active?).returns(true)
    assert @rating.display_moderation_message(@adminuser)
  end

  test "display report moderation message to owner" do
    @rating.stubs(:task_active?).returns(true)
    assert @rating.display_moderation_message(@person)
  end

  test "do not display report moderation message to regular user" do
    regular_person = fast_create(Person)
    @rating.stubs(:task_active?).returns(true)
    assert_not @rating.display_moderation_message(regular_person)
  end

  test "do not display report moderation message to not logged user" do
    @rating.stubs(:task_active?).returns(true)
    assert_not @rating.display_moderation_message(nil)
  end

  test "do not display report moderation message no active task exists" do
    @rating.stubs(:task_active?).returns(false)
    assert_not @rating.display_moderation_message(@person)
  end

  test "Create task for create a rating comment" do
    person = create_user('molly').person
    person.email = "person@email.com"
    person.save!

    community = fast_create(Community)
    community.add_admin(person)

    organization_rating = OrganizationRating.create!(
        :value => 3,
        :person => person,
        :organization => community
    )

    create_organization_rating_comment = CreateOrganizationRatingComment.create!(
      :requestor => person,
      :organization_rating_id => organization_rating.id,
      :target => community
    )

    assert community.tasks.include?(create_organization_rating_comment)
  end

  test "Should calculate community's rating average" do
    community = fast_create Community
    p1 = fast_create Person, :name=>"Person 1"
    p2 = fast_create Person, :name=>"Person 2"
    p3 = fast_create Person, :name=>"Person 3"

    OrganizationRating.create! :value => 2, :organization => community, :person => p1
    OrganizationRating.create! :value => 3, :organization => community, :person => p2
    OrganizationRating.create! :value => 5, :organization => community, :person => p3

    assert_equal 3, OrganizationRating.average_rating(community)

    p4 = fast_create Person, :name=>"Person 4"
    OrganizationRating.create! :value => 4, :organization => community, :person => p4

    assert_equal 4, OrganizationRating.average_rating(community)
  end
end
