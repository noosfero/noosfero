require File.dirname(__FILE__) + '/../../../../test/test_helper'

class StoaPlugin::Person < ActiveSupport::TestCase

  should 'validates uniqueness of usp_id' do
    usp_id = 12345678
    person = create_user('some-person').person
    person.usp_id = usp_id
    person.save!
    another_person = Person.new(:name => "Another person", :identifier => 'another-person', :usp_id => usp_id)

    assert !another_person.valid?
    assert another_person.errors.invalid?(:usp_id)
  end

end

