require File.dirname(__FILE__) + '/../../../../test/test_helper'

class StoaPlugin::Person < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(StoaPlugin)
  end

  attr_reader :environment

  should 'validates uniqueness of usp_id' do
    usp_id = 87654321
    fast_create(Person, :usp_id => usp_id)
    another_person = Person.new(:usp_id => usp_id)
    another_person.valid?

    assert another_person.errors.include?(:usp_id)
  end

  should 'not allow usp_id as an empty string' do
    person = Person.new(:usp_id => '')
    person.valid?

    assert_nil person.usp_id
  end

  should 'allow nil usp_id only if person has an invitation_code or is a template' do
    person = Person.new(:environment => environment)
    person.valid?
    assert person.errors.include?(:usp_id)

    Task.create!(:code => 12345678)
    person.invitation_code = 12345678
    person.valid?
    assert !person.errors.include?(:usp_id)

    person.invitation_code = nil
    person.is_template = true
    person.valid?
    assert !person.errors.include?(:usp_id)
  end

  should 'allow multiple nil usp_id' do
    fast_create(Person)
    Task.create!(:code => 87654321)
    person = Person.new(:invitation_code => 87654321)
    person.valid?

    assert !person.errors.include?(:usp_id)
  end

  should 'not allow person to be saved with a finished invitation that is not his own' do
    t = Task.create!(:code => 87654321, :target_id => 1)
    t.finish
    person = Person.new(:environment => environment, :invitation_code => 87654321)
    person.valid?

    assert person.errors.include?(:usp_id)
  end

  should 'allow person to be saved with a finished invitation if it is his own' do
    t = Task.create!(:code => 87654321)
    user = User.new(:login => 'some-person', :email => 'some-person@example.com', :password => 'test', :password_confirmation => 'test', :person_data => {:environment => environment, :invitation_code => 87654321})
    user.save!
    person = user.person
    t.target_id = person.id
    t.finish

    person.valid?
    assert !person.errors.include?(:usp_id)
  end


end

