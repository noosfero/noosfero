require_relative '../test_helper'

class EventPluginTest < ActiveSupport::TestCase

  should 'not crash' do
    EventPlugin.new
  end

end
