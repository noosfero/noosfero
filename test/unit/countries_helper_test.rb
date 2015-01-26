# encoding: UTF-8
require_relative "../test_helper"

class CountriesHelperTest < ActiveSupport::TestCase

  def setup
    @helper = CountriesHelper::Object.instance
  end
  attr_reader :helper

  should 'provide ISO-3166 list of countries' do
    assert_kind_of Array, CountriesHelper.countries

    # test some familiar countries and trust the rest is OK.
    assert CountriesHelper.countries.any? { |entry| entry.first == 'Brazil' }
    assert CountriesHelper.countries.any? { |entry| entry.first == 'France' }
    assert CountriesHelper.countries.any? { |entry| entry.first == 'Switzerland' }
  end

  should 'translate country names' do
    CountriesHelper.stubs(:countries).returns([["Brazil", "BR"],["France", "FR"]])
    helper.expects(:gettext).with("Brazil").returns("Brasil")
    helper.expects(:gettext).with("France").returns("França")
    assert_equal [["Brasil", "BR"], ["França", "FR"]], helper.countries
  end

  should 'sort alphabetically by the translated names' do
    CountriesHelper.stubs(:countries).returns([["Brazil", "BR"], ["Argentina", "AR"]])
    assert_equal [["Argentina", "AR"], ["Brazil", "BR"]], helper.countries
  end

  should 'sort respecting utf-8 ordering (or something like that)' do
    CountriesHelper.stubs(:countries).returns([["Brazil", "BR"], ["Åland Islands", "AX"]])
    assert_equal [["Åland Islands", "AX"], ["Brazil", "BR"]], helper.countries
  end

  should 'lookup country names by code' do
    assert_equal 'France', helper.lookup('FR')
    assert_equal 'Germany', helper.lookup('DE')
  end

  should 'translate lookups' do
    helper.expects(:gettext).with('Germany').returns('Alemanha')
    assert_equal 'Alemanha', helper.lookup('DE')
  end

end
