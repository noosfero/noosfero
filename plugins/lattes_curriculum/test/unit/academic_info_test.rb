require "test_helper"

class AcademicInfoTest < ActiveSupport::TestCase

  def setup
    @academic_info = AcademicInfo.new
  end

  should 'not ve invalid lattes url' do
    @academic_info.lattes_url = "http://softwarelivre.org/"
    assert !@academic_info.save
  end

  should 'accept blank lattes url' do
    @academic_info.lattes_url = ""
    assert @academic_info.save
  end

  should 'save with correct lattes url' do
    @academic_info.lattes_url = "http://lattes.cnpq.br/2193972715230641"
    assert @academic_info.save
  end
end
