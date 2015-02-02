require_relative "../test_helper"

class AccountHelperTest < ActiveSupport::TestCase

  include AccountHelper
  include ActionView::Helpers::TagHelper

  should 'not suggest usernames if username is empty' do
    assert_equal '', suggestion_based_on_username
  end

  should 'suggest valid usernames' do
    ze = create_user('ze').person
    stubs(:environment).returns(ze.environment)
    suggestions = suggestion_based_on_username('ze')
    suggestions.each do |suggestion|
      assert_equal true, Person.is_available?(suggestion, ze.environment)
    end
  end

  should 'remove chars which are not allowed' do
    stubs(:environment).returns(Environment.default)
    suggestions = suggestion_based_on_username('z/%&#e')
    suggestions.each do |suggestion|
      assert_no_match /.*%&#.*/, suggestion
    end
  end

  should 'return empty suggestions if do not find any identifier available' do
    stubs(:environment).returns(Environment.default)
    Person.stubs(:is_available?).returns(false)
    suggestions = suggestion_based_on_username('z/%&#e')
    assert_equal [], suggestions
  end

end
