require_relative 'test_helper'

class ProfilesTest < ActiveSupport::TestCase

  def setup
    Profile.delete_all
    login_api
  end

  should 'list all profiles' do
    person1 = fast_create(Person)
    person2 = fast_create(Person)
    community = fast_create(Community)
    get "/api/v1/profiles?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equivalent [person.id, person1.id, person2.id, community.id], json.map {|p| p['id']}
  end

  should 'get person from profile id' do
    some_person = fast_create(Person)
    get "/api/v1/profiles/#{some_person.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal some_person.id, json['id']
  end

  should 'get community from profile id' do
    community = fast_create(Community)
    get "/api/v1/profiles/#{community.id}?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal community.id, json['id']
  end

  group_kinds = %w(community enterprise)
  group_kinds.each do |kind|
    should "delete #{kind} from profile id with permission" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      give_permission(@person, 'destroy_profile', profile)
      assert_not_nil Profile.find_by_id profile.id

      delete "/api/v1/profiles/#{profile.id}?#{params.to_query}"

      assert_equal 200, last_response.status
      assert_nil Profile.find_by_id profile.id
    end

    should "not delete #{kind} from profile id without permission" do
      profile = fast_create(kind.camelcase.constantize, :environment_id => environment.id)
      assert_not_nil Profile.find_by_id profile.id

      delete "/api/v1/profiles/#{profile.id}?#{params.to_query}"

      assert_equal 403, last_response.status
      assert_not_nil Profile.find_by_id profile.id
    end
  end

  should 'person delete itself' do
    delete "/api/v1/profiles/#{@person.id}?#{params.to_query}"
    assert_equal 200, last_response.status
    assert_nil Profile.find_by_id @person.id
  end

  should 'only admin delete other people' do
    profile = fast_create(Person, :environment_id => environment.id)
    assert_not_nil Profile.find_by_id profile.id

    delete "/api/v1/profiles/#{profile.id}?#{params.to_query}"

    assert_equal 403, last_response.status
    assert_not_nil Profile.find_by_id profile.id

    environment.add_admin(@person)

    delete "/api/v1/profiles/#{profile.id}?#{params.to_query}"

    assert_equal 200, last_response.status
    assert_nil Profile.find_by_id profile.id

  end
end
