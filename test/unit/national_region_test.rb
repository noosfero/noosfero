require_relative "../test_helper"

class NationalRegionTest < ActiveSupport::TestCase
  
  should 'search_city especific city' do
    city_name = "Santos"

    new_region = fast_create(NationalRegion, :name =>  city_name,
                                :national_region_code => '355030',
                                :national_region_type_id => NationalRegionType::CITY)

    found_region = NationalRegion.search_city(city_name)

    assert_equal new_region.name, found_region.city
    assert_equal new_region.national_region_code, found_region.national_region_code
  end

  should 'search_city like cities' do
    city_names = [ "Santo Afonso", "Santo Antonio", "Santo Augusto" ]
    new_regions = []

    for i in 0..city_names.length
      new_regions << fast_create(NationalRegion, :name =>  city_names[i],
        :national_region_code => '355030',
        :national_region_type_id => NationalRegionType::CITY)
    end

    found_regions = NationalRegion.search_city('Santo %', true)
    
    refute (found_regions.length != 3)

    found_regions.each do |region|
      assert city_names.find_index(region.city) >=  0
    end

  end

  should 'search_city especific state' do
    state_name = "Santa Catarina"

    new_region = fast_create(NationalRegion, :name =>  state_name,
                                :national_region_code => '22',
                                :national_region_type_id => NationalRegionType::STATE)

    found_region = NationalRegion.search_state(state_name)

    assert_equal new_region.name, found_region.state
    assert_equal new_region.national_region_code, found_region.national_region_code
  end

  should 'search_city like states' do
    state_names = [ "Rio de Janeiro", "Rio Grande do Norte", "Rio Grande do Sul" ]
    new_regions = []

    for i in 0..state_names.length
      new_regions << fast_create(NationalRegion, :name =>  state_names[i],
        :national_region_code => '35',
        :national_region_type_id => NationalRegionType::STATE)
    end

    found_regions = NationalRegion.search_state('Rio %', true)

    refute (found_regions.length != 3)

    found_regions.each do |region|
      assert state_names.find_index(region.state) >=  0
    end

  end
end
