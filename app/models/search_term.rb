class SearchTerm < ActiveRecord::Base
  validates_presence_of :term, :context
  validates_uniqueness_of :term, :scope => [:context_id, :context_type, :asset]

  belongs_to :context, :polymorphic => true
  has_many :occurrences, :class_name => 'SearchTermOccurrence'

  attr_accessible :term, :context, :asset

  def self.calculate_scores
    find_each { |search_term| search_term.calculate_score }
  end

  def self.find_or_create(term, context, asset='all')
    context.search_terms.where(:term => term, :asset => asset).first || context.search_terms.create!(:term => term, :asset=> asset)
  end

  before_save :calculate_score

  def calculate_score
    valid_occurrences = occurrences.valid
    if valid_occurrences.present?
      indexed = valid_occurrences.last.indexed
      total = valid_occurrences.last.total
      # Using the formula described on this paper: http://www.soi.city.ac.uk/~ser/papers/RSJ76.pdf
      current_relevance = indexed > 0 && total >= indexed ? -Math.log(indexed.to_f/total.to_f) : 0
      # Damp number of occurrences with log function to decrease it's effect over relevance.
      damped_occurrences = Math.log(valid_occurrences.count)
      self.score = (damped_occurrences * current_relevance).to_f
    else
      self.score = 0
    end
  end
end
