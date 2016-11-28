class PgSearchPlugin::SearchFacetOccurrence < ApplicationRecord
  belongs_to :environment
  belongs_to :target, polymorphic: true

  validates_presence_of :environment, :asset

  attr_accessible :environment, :asset, :target, :attribute_name, :value
end
