# Affiliation it is a join model to hold affiliations of people to others profiles
class Affiliation < ActiveRecord::Base
  belongs_to :person
  belongs_to :profile
end
