require File.dirname(__FILE__) + '/../test_helper'

class PersonInfoTest < Test::Unit::TestCase

  should 'provide desired fields' do 
    info = PersonInfo.new
  
    assert info.respond_to?(:photo)
    assert info.respond_to?(:address)
    assert info.respond_to?(:contact_information)
  end

end
