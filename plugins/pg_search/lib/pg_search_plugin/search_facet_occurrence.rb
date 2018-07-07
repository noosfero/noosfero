class PgSearchPlugin::SearchFacetOccurrence < ApplicationRecord
  belongs_to :environment, optional: true
  belongs_to :target, polymorphic: true, optional: true

  validates_presence_of :environment, :asset

  attr_accessible :environment, :asset, :target, :attribute_name, :value
end
