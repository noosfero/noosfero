require File.dirname(__FILE__) + '/../test_helper'

class CertifierTest < Test::Unit::TestCase

  should 'have link' do
    certifier = Certifier.new

    assert_equal '', certifier.link

    certifier.link = 'http://noosfero.org'
    assert_equal 'http://noosfero.org', certifier.link
  end

end
