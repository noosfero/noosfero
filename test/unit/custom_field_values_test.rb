require_relative "../test_helper"

class CustomFieldValuesTest < ActiveSupport::TestCase

  should 'custom field value not be valid' do
    c = CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    person = create_user('testinguser').person

    cv=CustomFieldValue.new(:customized => person, :custom_field => c, :value => "")
    refute cv.valid?
  end

  should 'return only public custom field values in public scope' do
    c = CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    person = create_user('testinguser').person
    cfv = CustomFieldValue.create(:value => 'value1', :public => true, :customized => person, :custom_field => c)
    c = CustomField.create!(:name => "Another", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    CustomFieldValue.create(:value => 'value2', :public => false, :customized => person, :custom_field => c)
    assert_equal [cfv], CustomFieldValue.only_public
  end

  should 'return only non public custom field values in not_public scope' do
    c = CustomField.create!(:name => "Blog", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    person = create_user('testinguser').person
    CustomFieldValue.create(:value => 'value1', :public => true, :customized => person, :custom_field => c)
    c = CustomField.create!(:name => "Another", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    cfv = CustomFieldValue.create(:value => 'value2', :public => false, :customized => person, :custom_field => c)
    assert_equal [cfv], CustomFieldValue.not_public
  end

  should 'return custom field value by custom field name' do
    c = CustomField.create!(:name => "some", :format => "string", :customized_type => "Person", :active => true, :required => true, :environment => Environment.default)
    person = create_user('testinguser').person
    cfv = CustomFieldValue.create(:value => 'value1', :public => true, :customized => person, :custom_field => c)
    assert_equal [cfv], CustomFieldValue.by_field('some')
  end
end
