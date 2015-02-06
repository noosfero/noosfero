require 'test_helper'

class SearchTermOccurrenceTest < ActiveSupport::TestCase

  def setup
    @search_term = SearchTerm.find_or_create('universe', Environment.default)
  end

  attr_reader :search_term

  should 'have term' do
    search_term_occurrence = SearchTermOccurrence.new
    assert !search_term_occurrence.valid?
    assert search_term_occurrence.errors.has_key?(:search_term)
  end

  should 'create a search term occurence' do
    assert_nothing_raised do
      SearchTermOccurrence.create!(:search_term => search_term)
    end
  end

  should 'fetch only valid occurrences' do
    o1 = SearchTermOccurrence.create!(:search_term => search_term)
    o2 = SearchTermOccurrence.create!(:search_term => search_term)
    o3 = SearchTermOccurrence.create!(:search_term => search_term, :created_at => DateTime.now - (SearchTermOccurrence::EXPIRATION_TIME + 1.day))

    assert_equivalent [o1,o2], search_term.occurrences.valid
  end
end
