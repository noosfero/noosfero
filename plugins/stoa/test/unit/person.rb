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

    assert another_person.errors.invalid?(:usp_id)
  end

  should 'allow nil usp_id only if person has an invitation_code' do
    person = Person.new(:environment => environment)
    person.valid?
    assert person.errors.invalid?(:usp_id)

    Task.create!(:code => 12345678)
    person.invitation_code = 12345678
    person.valid?

    assert !person.errors.invalid?(:usp_id)
  end

  should 'allow multiple nil usp_id' do
    fast_create(Person)
    Task.create!(:code => 87654321)
    person = Person.new(:invitation_code => 87654321)
    person.valid?

    assert !person.errors.invalid?(:usp_id)
  end

  should 'not allow person register with a finished task' do
    t = Task.create!(:code => 87654321)
    t.finish
    person = Person.new(:environment => environment, :invitation_code => 87654321)
    person.valid?

    assert person.errors.invalid?(:usp_id)
  end

end

