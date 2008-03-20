require File.dirname(__FILE__) + '/../../../../config/environment'
load(File.dirname(__FILE__) + '/schema.rb')

class Pub < ActiveRecord::Base
  set_table_name :nested_has_many_through_pubs
end

class City < ActiveRecord::Base
  set_table_name :nested_has_many_through_cities
  has_many :pubs
end

class Country < ActiveRecord::Base
  set_table_name :nested_has_many_through_countries
  has_many :cities
  has_many :pubs, :through => :cities
end

class Planet < ActiveRecord::Base
  set_table_name :nested_has_many_through_planets
  has_many :countries
  has_many :cities, :through => :countries
  has_many :pubs, :through => :cities
end
