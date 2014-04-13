require File.dirname(__FILE__) + '/../test_helper'

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

end
