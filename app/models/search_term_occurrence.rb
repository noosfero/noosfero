class SearchTermOccurrence < ApplicationRecord
  belongs_to :search_term, optional: true
  validates_presence_of :search_term
  attr_accessible :search_term, :created_at, :total, :indexed

  EXPIRATION_TIME = 1.year

  scope :valid, -> { where "search_term_occurrences.created_at > ?", DateTime.now - EXPIRATION_TIME }
end
