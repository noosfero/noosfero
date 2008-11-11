require File.dirname(__FILE__) + '/../test_helper'

class CreateEnterpriseTest < Test::Unit::TestCase

  should 'provide needed data' do
    task = CreateEnterprise.new

    %w[ name identifier address contact_phone contact_person acronym foundation_year economic_activity ].each do |field|
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
    task.requestor = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person
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

  should 'require an explanation for rejecting enterprise creation' do
    task = CreateEnterprise.new
    task.reject_explanation = nil

    task.valid?
    assert !task.errors.invalid?(:reject_explanation)

    task.status = Task::Status::CANCELLED
    task.valid?
    assert task.errors.invalid?(:reject_explanation)

    task.reject_explanation = 'bla bla bla'
    task.valid?
    assert !task.errors.invalid?(:reject_explanation)
  end

  should 'finish task when approved' do
    task = CreateEnterprise.new
    task.expects(:finish)
    task.approve
  end

  should 'actually create an enterprise when finishing the task and associate the task requestor as its owner through the "user" association' do

    Environment.destroy_all
    environment = Environment.create!(:name => "My environment", :contact_email => 'test@localhost.localdomain', :is_default => true)
    region = Region.create!(:name => 'My region', :environment_id => environment.id)
    validator = Organization.create!(:name => "My organization", :identifier => 'myorg', :environment_id => environment.id)
    region.validators << validator
    person = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person

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
    assert_equal person.user, enterprise.user
    assert_equal environment, enterprise.environment

    # the data is not erased
    assert_equal task.name, enterprise.name
  end

  should 'actually create an enterprise when finishing the task and associate the task requestor as its owner through the "user" association even when environment is not default' do

    environment = Environment.create!(:name => "My environment", :contact_email => 'test@localhost.localdomain')
    region = Region.create!(:name => 'My region', :environment_id => environment.id)
    validator = Organization.create!(:name => "My organization", :identifier => 'myorg', :environment_id => environment.id)
    region.validators << validator
    person = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person

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
    assert_equal person.user, enterprise.user
    assert_equal environment, enterprise.environment

    # the data is not erased
    assert_equal task.name, enterprise.name
  end

  should 'override message methods from Task' do
    generic = Task.new
    specific = CreateEnterprise.new
    %w[ task_created_message task_finished_message task_cancelled_message ].each do |method|
      assert_not_equal generic.send(method), specific.send(method)
    end
  end

  should 'validate that eveything is ok but the validator (target)' do
    Environment.destroy_all
    environment = Environment.create!(:name => "My environment", :contact_email => 'test@localhost.localdomain', :is_default => true)
    region = Region.create!(:name => 'My region', :environment_id => environment.id)
    validator = Organization.create!(:name => "My organization", :identifier => 'myorg', :environment_id => environment.id)
    region.validators << validator
    person = create_user('testuser', :password => 'test', :password_confirmation => 'test', :email => 'testuser@localhost.localdomain').person
    task = CreateEnterprise.new({
      :name => 'My new enterprise',
      :identifier => 'mynewenterprise',
      :address => 'satan street, 666',
      :contact_phone => '1298372198',
      :contact_person => 'random joe',
      :legal_form => 'cooperative',
      :economic_activity => 'free software',
      :region_id => region.id,
      :requestor_id => person.id,
    })

    assert !task.valid? && task.valid_before_selecting_target?

    task.target = validator
    assert task.valid?
  end

  should 'provide a message to be sent to the target' do
    assert_not_nil CreateEnterprise.new.target_notification_message
  end

  should 'report as approved when approved' do
    request = CreateEnterprise.new
    request.stubs(:status).returns(Task::Status::FINISHED)
    assert request.approved?
  end

  should 'report as rejected when rejected' do
    request = CreateEnterprise.new
    request.stubs(:status).returns(Task::Status::CANCELLED)
    assert request.rejected?
  end

  should 'refuse to create an enterprise creation request with an identifier already used by another profile' do
    request = CreateEnterprise.new
    request.identifier = 'testid'
    request.valid?
    assert !request.errors.invalid?(:identifier)

    Organization.create!(:name => 'test', :identifier => 'testid')
    request.valid?
    assert request.errors.invalid?(:identifier)
  end

  should 'has permission to validate enterprise' do
    t = CreateEnterprise.new
    assert_equal :validate_enterprise, t.permission
  end
end
