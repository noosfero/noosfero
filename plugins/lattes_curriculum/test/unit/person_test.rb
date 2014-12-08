require "test_helper"

class PersonTest < ActiveSupport::TestCase

  def setup
    @environment = Environment.default
    @environment.enable_plugin(LattesCurriculumPlugin)
  end

  attr_reader :environment

  should 'destroy academic info if person is removed' do
    person = fast_create(Person)
    academic_info = fast_create(AcademicInfo, :person_id => person.id,
:lattes_url => 'http://lattes.cnpq.br/2193972715230')

    assert_difference 'AcademicInfo.count', -1 do
      person.destroy
    end
  end

  should 'add lattes_url field to Person' do
    assert_includes Person.fields, 'lattes_url'
  end

end
