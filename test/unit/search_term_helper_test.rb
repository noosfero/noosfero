require File.dirname(__FILE__) + '/../test_helper'

class SearchTermTest < ActiveSupport::TestCase

  include SearchTermHelper

  should 'register search term' do
    environment = Environment.default
    assert_difference 'SearchTerm.count', 1 do
      register_search_term('fred mercury', 10, 1, environment, 'people')
    end
  end

  should 'register search term normalized' do
    environment = Environment.default
    assert_difference 'SearchTerm.count', 1 do
      register_search_term('FrEd mErCuRy', 10, 1, environment, 'people')
      register_search_term('fReD MeRcUrY', 10, 1, environment, 'people')
      assert SearchTerm.find_or_create('fred mercury', environment, 'people')
    end
  end

end
