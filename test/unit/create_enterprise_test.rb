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
    task = CreateEnterprise.new
    task.valid?

    assert task.errors.invalid?(:target_id)
    task.target = Organization.create!(:name => "My organization", :identifier => 'validator_organization')

    task.valid?
    assert !task.errors.invalid?(:target_id)
  end

  should 'require that the informed target (validator organization) actually validates for the chosen region' do
    environment = Environment.create!(:name => "My environment")
    region = Region.create!(:name => 'My region', :environment_id => environment.id)
    validator = Organization.create!(:name => "My organization", :identifier => 'myorg', :environment_id => environment.id)

    task = CreateEnterprise.new

    task.region = region
    task.target = validator

    task.valid?
    assert task.errors.invalid?(:target)
    
    region.validators << validator

    task.valid?
    assert !task.errors.invalid?(:target)
  end

  should 'cancel task when rejected ' do
    task = CreateEnterprise.new
    task.expects(:cancel)
    task.reject
  end

  should 'finish task when approved' do
    task = CreateEnterprise.new
    task.expects(:finish)
    task.approve
  end

  should 'actually create an enterprise when finishing the task' do

    Environment.destroy_all
    environment = Environment.create!(:name => "My environment", :contact_email => 'test@localhost.localdomain', :is_default => true)
    region = Region.create!(:name => 'My region', :environment_id => environment.id)
    validator = Organization.create!(:name => "My organization", :identifier => 'myorg', :environment_id => environment.id)
    region.validators << validator
    person = User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person

    task = CreateEnterprise.create!({
      :name => 'My new enterprise',
      :identifier => 'mynewenterprise',
      :address => 'satan street, 666',
      :contact_phone => '1298372198',
      :contact_person => 'random joe',
      :legal_form => 'cooperative',
      :economic_activity => 'free software',
      :region_id => region.id,
      :requestor_id => person.id,
      :target_id => validator.id,
    })

    enterprise = Enterprise.new
    Enterprise.expects(:new).returns(enterprise)

    task.finish

    assert !enterprise.new_record?
  end

  should 'associate task requestor as enterprise administrator upon enterprise creation' do

    Environment.destroy_all
    environment = Environment.create!(:name => "My environment", :contact_email => 'test@localhost.localdomain', :is_default => true)
    region = Region.create!(:name => 'My region', :environment_id => environment.id)
    validator = Organization.create!(:name => "My organization", :identifier => 'myorg', :environment_id => environment.id)
    region.validators << validator
    person = User.create!(:login => 'testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person

    task = CreateEnterprise.create!({
      :name => 'My new enterprise',
      :identifier => 'mynewenterprise',
      :address => 'satan street, 666',
      :contact_phone => '1298372198',
      :contact_person => 'random joe',
      :legal_form => 'cooperative',
      :economic_activity => 'free software',
      :region_id => region.id,
      :requestor_id => person.id,
      :target_id => validator.id,
    })

    enterprise = Enterprise.new
    Enterprise.expects(:new).returns(enterprise)

    task.finish


    flunk "don't know howt to test it yet"
  end

end
