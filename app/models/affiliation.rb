class Affiliation < ActiveRecord::Base
  belongs_to :person
  belongs_to :profile
end
