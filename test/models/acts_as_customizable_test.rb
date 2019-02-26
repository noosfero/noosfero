require_relative "../test_helper"

class ActsAsCustomizableTest < ActiveSupport::TestCase

  should 'save custom field values for person' do
    CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default)
    person = create_user('testinguser').person
    assert_difference 'CustomFieldValue.count' do
      person.custom_values = { "Blog" => { "value" => "www.blog.org", "public" => "0"} }
      person.save!
      assert_equal 'www.blog.org', CustomFieldValue.where(customized_id: person.id).last.value
    end
  end

  should 'not be valid when required custom field not filled' do
    CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true, :environment => Environment.default, :required => true)
    person = create_user('testinguser').person

    person.custom_values = { "Blog" => { "value" => "", "public" => "0"} }
    refute person.valid?
  end

end
