require_relative 'test_helper'

class ActivitiesTest < ActiveSupport::TestCase

  def setup
    login_api
  end

  should 'get activity from profile' do
    person = fast_create(Person)
    organization = fast_create(Organization)
    assert_difference 'organization.activities_count' do
      ActionTracker::Record.create! :verb => :leave_scrap, :user => person, :target => organization
      organization.reload
    end
    get "/api/v1/profiles/#{organization.id}/activities?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert 1, json["activities"].count
    assert_equal organization.activities.map(&:activity).first.id, json["activities"].first["id"]
  end

end
