require 'test_helper'

class PersonTeste < ActiveSupport::TestCase
  def setup
    @person = fast_create(Person)
    @profile = fast_create(Profile)
  end

  should 'display summary if its owner profile' do
    assert @person.can_see_summary?(@person)
  end

  should 'display summary to environment admin' do
    Environment.default.add_admin @person
    assert @person.can_see_summary?(@profile)
  end

  should 'display summary if person is a profile admin' do
    @profile.add_admin @person
    assert @person.can_see_summary?(@profile)
  end

  should 'not display summary if is a person without permissions' do
    refute @person.can_see_summary?(@profile)
  end
end
