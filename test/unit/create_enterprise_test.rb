require File.dirname(__FILE__) + '/../test_helper'

class CreateEnterpriseTest < Test::Unit::TestCase

  should 'provide needed data' do
    task = CreateEnterprise.new

    %w[ name identifier address contact_phone contact_person acronym foundation_year legal_form economic_activity management_information ].each do |field|
      assert task.respond_to?(field)
      assert task.respond_to?("#{field}=")
    end
  end
  
  should 'accept only numbers as foundation year' do
    task = CreateEnterprise.new

    task.foundation_year = "test"
    task.valid?
    assert task.errors.invalid?(:foundation_year)

    task.foundation_year = 2006
    task.valid?
    assert !task.errors.invalid?(:foundation_year)
  end

  should 'require a requestor' do
    task = CreateEnterprise.new
    task.valid?

    assert task.errors.invalid?(:requestor_id)
    task.requestor = User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person
    task.valid?
    assert !task.errors.invalid?(:requestor_id)
  end

  should 'require a target (validator organization)' do
    flunk 'need to write'
  end

  should 'associate task requestor as enterprise administrator when creating' do
    flunk 'need to write'
  end

end
