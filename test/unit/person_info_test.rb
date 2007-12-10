require File.dirname(__FILE__) + '/../test_helper'

class PersonInfoTest < Test::Unit::TestCase

  should 'provide desired fields' do 
    info = PersonInfo.new
  
    assert info.respond_to?(:photo)
    assert info.respond_to?(:address)
    assert info.respond_to?(:contact_information)
  end

  should 'provide needed information in summary' do
    person_info = PersonInfo.new

    person_info.name = 'person name'
    person_info.address = 'my address'
    person_info.contact_information = 'my contact information'

    summary = person_info.summary
    assert(summary.any? { |line| line[1] == 'person name' })
    assert(summary.any? { |line| line[1] == 'my address' })
    assert(summary.any? { |line| line[1] == 'my contact information' }, "summary (#{summary.map{|l| l[1] }.compact.join("; ")}) do not contain 'my contact informatidon'")
  end

end
