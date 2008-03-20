require 'test/unit'
require File.join(File.dirname(__FILE__), 'helper')

class NestedHasManyThroughTest < Test::Unit::TestCase

  def test_nested_has_many_through

    planet = Planet.create!
    pubs = []
    2.times do
       planet.countries.build.save!
       planet.countries.each do |country|
         2.times do
           country.cities.build.save!
         end
         country.cities.each do |city|
           pubs << city.pubs.build
           pubs.last.save!
         end
       end
    end

    assert_equal pubs, planet.pubs

  end
end
