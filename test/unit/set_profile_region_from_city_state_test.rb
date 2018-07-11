require_relative "../test_helper"

class SetProfileRegionFromCityStateTest < ActiveSupport::TestCase

  should 'set city and state from names' do
    c, _ = create_city_in_state('Pindamonhangaba', 'Sao Paulo', 'SP')

    p = fast_create(Person, user_id: fast_create(User).id)
    p.state = 'SP'
    p.city = 'Pindamonhangaba'
    p.save!
    assert_equal p.region, c
  end

  should 'set region to null if city not found' do
    create_city_in_state(nil, 'Sao Paulo', 'SP')

    p = fast_create(Person, user_id: fast_create(User).id)
    p.state = 'SP'
    p.city = 'Pindamonhangaba'
    p.save!
    assert_nil p.region
  end

  should 'set region to null if state not found' do
    create_city_in_state('Pindamonhangaba', 'Sao Paulo', 'SP')

    p = fast_create(Person, user_id: fast_create(User).id)
    p.state = 'RJ'
    p.city = 'Pindamonhangaba'
    p.save!
    assert_nil p.region
  end

  def create_city_in_state(city_name, state_name, state_acronym)
    environment_id = Environment.default.id

    state = State.new(name: state_name, acronym: state_acronym)
    state.environment_id = environment_id
    state.save!

    city = nil
    if city_name
      city = City.new(name: city_name, parent_id: state.id)
      city.environment_id = environment_id
      city.save!
    end

    return [city, state]
  end

end
