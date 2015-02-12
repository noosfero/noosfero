require File.dirname(__FILE__) + '/../../../../test/test_helper'

class EventPluginTest < ActiveSupport::TestCase

  should 'not crash' do
    EventPlugin.new
  end

end
