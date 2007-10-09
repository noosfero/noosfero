
require File.dirname(__FILE__) + '/../test_helper'

require 'noosfero/url'

class NoosferoURLTest < Test::Unit::TestCase

  include Noosfero::URL

  def setup
    Noosfero::URL.instance_variable_set('@config', nil)
  end

  should 'read the config file' do
    file = "#{RAILS_ROOT}/config/web.yml"
    File.expects(:exists?).with(file).returns(true)
    YAML.expects(:load_file).with(file).returns('path' => '/mypath', 'port' => 9999)
    assert_equal({'path' => '/mypath', 'port' => 9999}, Noosfero::URL.config)
  end

  should 'fallback correcly' do
    file = "#{RAILS_ROOT}/config/web.yml"
    File.expects(:exists?).with(file).returns(false)
    assert_equal({'path' => '', 'port' => 3000}, Noosfero::URL.config)
  end

  should 'read the correct path' do
    Noosfero::URL.stubs(:config).returns('path' => '/mypath')
    assert_equal '/mypath', self.path
  end

  should 'read the correct port' do
    Noosfero::URL.stubs(:config).returns('port' => 9999)
    assert_equal 9999, self.port
  end

  should 'add path when needed' do
    self.stubs(:path).returns('/somepath')
    self.stubs(:port).returns(nil)
    assert_equal('http://example.com/somepath/', generate_url(:host => 'example.com', :controller => 'home'))
  end

  should 'not add path when it is not needed' do
    self.stubs(:path).returns(nil)
    self.stubs(:port).returns(nil)
    assert_equal('http://example.com/', generate_url(:host => 'example.com', :controller => 'home'))
  end

end
