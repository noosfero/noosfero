require File.dirname(__FILE__) + '/../test_helper'

class PluginTest < Test::Unit::TestCase

  def setup
    @environment = Environment.default
  end
  attr_reader :environment

  should 'keep the list of all loaded subclasses' do
    class Plugin1 < Noosfero::Plugin
    end

    class Plugin2 < Noosfero::Plugin
    end

    assert_includes  Noosfero::Plugin.all, Plugin1.to_s
    assert_includes  Noosfero::Plugin.all, Plugin1.to_s
  end

end


