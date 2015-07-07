require 'test_helper'

class VarnishConfTest < ActiveSupport::TestCase

   def test_not_use_return_in_varnish_noosfero
    assert !system('grep "return.*pass" etc/noosfero/varnish-noosfero.vcl')
  end

end
