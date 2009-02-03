require File.dirname(__FILE__) + '/../test_helper'

class EmailActivationTest < Test::Unit::TestCase

  should 'require a requestor' do
    task = EmailActivation.new
    task.valid?

    assert task.errors.invalid?(:requestor_id)
  end

  should 'require a target (environment)' do
    task = EmailActivation.new
    task.valid?

    assert task.errors.invalid?(:target_id)
  end

  should 'enable user email when finish' do
    ze = create_user('zezinho', :environment_id => Environment.default.id)
    assert !ze.enable_email
    task = EmailActivation.create!(:requestor => ze.person, :target => Environment.default)
    task.finish
    ze.reload
    assert ze.enable_email
  end

  should 'create only once pending task by user' do
    ze = create_user('zezinho', :environment_id => Environment.default.id)
    task = EmailActivation.new(:requestor => ze.person, :target => Environment.default)
    assert task.save!

    anothertask = EmailActivation.new(:requestor => ze.person, :target => Environment.default)
    assert !anothertask.save
  end

  should 'display email address on description of task' do
    ze = create_user('zezinho', :environment_id => Environment.default.id)
    Environment.default.domains = [Domain.create!(:name => 'env_test.invalid')]
    task = EmailActivation.new(:requestor => ze.person, :target => Environment.default)
    assert_match /zezinho@env_test.invalid/, task.description
  end

end
