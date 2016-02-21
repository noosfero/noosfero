class SearchTerm < ApplicationRecord
  validates_presence_of :term, :context
  validates_uniqueness_of :term, :scope => [:context_id, :context_type, :asset]

  belongs_to :context, :polymorphic => true
  has_many :occurrences, :class_name => 'SearchTermOccurrence'

  attr_accessible :term, :context, :asset

  def self.calculate_scores
    os = occurrences_scores
    find_each { |search_term| search_term.calculate_score(os) }
  end

  def self.find_or_create(term, context, asset='all')
    context.search_terms.where(:term => term, :asset => asset).first || context.search_terms.create!(:term => term, :asset=> asset)
  end

  # Fast way of getting the occurrences score for each search_term. Ugly but fast!
  #
  # Each occurrence of a search_term has a score that is smaller the older the
  # occurrence happened. We subtract the amount of time between now and the
  # moment it happened from the total time any occurrence is valid to happen. E.g.:
  # The expiration time is 100 days and an occurrence happened 3 days ago.
  # Therefore the score is 97. Them we sum every score to get the total score
  # for a search term.
  def self.occurrences_scores
    Hash[*ApplicationRecord.connection.execute(
      joins(:occurrences).
      select("search_terms.id, sum(#{SearchTermOccurrence::EXPIRATION_TIME.to_i} - extract(epoch from (now() - search_term_occurrences.created_at))) as value").
      where("search_term_occurrences.created_at > ?", DateTime.now - SearchTermOccurrence::EXPIRATION_TIME).
      group("search_terms.id").
      order('value DESC').
      to_sql
    ).map {|result| [result['id'].to_i, result['value'].to_i]}.flatten]
  end

  def calculate_occurrence(occurrences_scores)
    max_score = occurrences_scores.first[1]
    (occurrences_scores[id]/max_score.to_f)*100
  end

  def calculate_relevance(valid_occurrences)
    indexed = valid_occurrences.last.indexed.to_f
    return 0 if indexed == 0
    total = valid_occurrences.last.total.to_f
    (1 - indexed/total)*100
  end

  def calculate_score(occurrences_scores)
    valid_occurrences = occurrences.valid
    if valid_occurrences.present?
      # These scores vary from 1~100
      self.occurrence_score = calculate_occurrence(occurrences_scores)
      self.relevance_score = calculate_relevance(valid_occurrences)
    else
      self.occurrence_score = 0
      self.relevance_score = 0
    end
    self.score = (occurrence_score * relevance_score)/100.0
    self.save!
  end
end
