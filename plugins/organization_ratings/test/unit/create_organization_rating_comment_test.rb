require 'test_helper'
class CreateOrganizationRatingCommentTest < ActiveSupport::TestCase

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

  test "create comment when finish TASK" do
    create_organization_rating_comment = CreateOrganizationRatingComment.create!(
      :requestor => @person,
      :organization_rating_id => @rating.id,
      :target => @community,
      :body => "sample comment"
    )
    assert_equal Task::Status::ACTIVE, create_organization_rating_comment.status
    assert_difference 'Comment.count' do
      create_organization_rating_comment.finish
    end
  end

  test "do not create comment when cancel TASK" do
    create_organization_rating_comment = CreateOrganizationRatingComment.create!(
      :requestor => @person,
      :organization_rating_id => @rating.id,
      :target => @community,
      :body => "sample comment"
    )
    assert_equal Task::Status::ACTIVE, create_organization_rating_comment.status
    assert_no_difference 'Comment.count' do
      create_organization_rating_comment.cancel
    end
  end

end
