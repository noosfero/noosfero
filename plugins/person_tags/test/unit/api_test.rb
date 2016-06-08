require_relative '../test_helper'
require_relative '../../../../test/api/test_helper'

class APITest <  ActiveSupport::TestCase

  def setup
    create_and_activate_user
    environment.enable_plugin(PersonTagsPlugin)
  end

  should 'return tags for a person' do
    person = create_user('person').person
    person.interest_list.add('linux')
    person.save!
    person.reload
    get "/api/v1/people/#{person.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal ['linux'], json
  end

  should 'return empty list if person has no tags' do
    person = create_user('person').person
    get "/api/v1/people/#{person.id}/tags?#{params.to_query}"
    json = JSON.parse(last_response.body)
    assert_equal [], json
  end
end
