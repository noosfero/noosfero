require File.dirname(__FILE__) + '/../../../../test/test_helper'

class FooPluginTest < ActiveSupport::TestCase
  def test_foo
    FooPlugin::Bar.create!
  end
  def test_monkey_patch
    Profile.new.bar
  end
end
