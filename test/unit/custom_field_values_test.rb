require_relative "../test_helper"

class CustomFieldValuesTest < ActiveSupport::TestCase

  should 'custom field value not be valid' do
    c = CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    person = create_user('testinguser').person

    cv=CustomFieldValue.new(:customized => person, :custom_field => c, :value => "")
    refute cv.valid?
  end
end
