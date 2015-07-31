require 'test/unit'

class VarnishConfTest < Test::Unit::TestCase

   def test_not_use_return_in_varnish_noosfero
    refute system('grep "return.*pass" etc/noosfero/varnish-noosfero.vcl')
  end

end
