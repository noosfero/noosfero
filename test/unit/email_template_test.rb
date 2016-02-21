require_relative "../test_helper"

class EmailTemplateTest < ActiveSupport::TestCase

  should 'filter templates by type' do
    EmailTemplate.create!(:template_type => :type1, :name => 'template1')
    EmailTemplate.create!(:template_type => :type2, :name => 'template2')
    EmailTemplate.create!(:template_type => :type2, :name => 'template3')
    assert_equal ['template2', 'template3'], EmailTemplate.where(template_type: :type2).map(&:name)
  end

  should 'parse body using params' do
    template = EmailTemplate.new(:body => 'Hi {{person}}')
    assert_equal 'Hi John', template.parsed_body({:person => 'John'})
  end

  should 'parse subject using params' do
    template = EmailTemplate.new(:subject => 'Hi {{person}}')
    assert_equal 'Hi John', template.parsed_subject({:person => 'John'})
  end

  should 'not create template with the same name of other' do
    template1 = EmailTemplate.new(:template_type => :type1, :name => 'template', :owner => Environment.default)
    template2 = EmailTemplate.new(:template_type => :type1, :name => 'template', :owner => Environment.default)
    assert template1.save
    assert !template2.save
  end

  should 'not create duplicated template when template type is unique' do
    template1 = EmailTemplate.new(:template_type => :user_activation, :name => 'template1', :owner => Environment.default)
    template2 = EmailTemplate.new(:template_type => :user_activation, :name => 'template2', :owner => Environment.default)
    assert template1.save
    assert !template2.save
  end

  should 'create duplicated template when template type is not unique' do
    template1 = EmailTemplate.new(:template_type => :task_rejection, :name => 'template1', :owner => Environment.default)
    template2 = EmailTemplate.new(:template_type => :task_rejection, :name => 'template2', :owner => Environment.default)
    assert template1.save
    assert template2.save
  end

  should 'return available types when the owner is an environment' do
    template = EmailTemplate.new(:owner => Environment.default)
    assert_equal [:user_activation, :user_change_password], template.available_types.symbolize_keys.keys
  end

  should 'return available types when the owner is a profile' do
    template = EmailTemplate.new(:owner => Profile.new)
    assert_equal [:task_rejection, :task_acceptance, :organization_members], template.available_types.symbolize_keys.keys
  end

end
