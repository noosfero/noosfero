require 'test_helper'

class GoogleCsePluginTest < ActiveSupport::TestCase

  def setup
    @plugin = GoogleCsePlugin.new
    @context = mock()
    @plugin.context = @context
    @env = Environment.new
    @plugin.context.stubs(:environment).returns(@env)
  end

  should 'get google_id from environment' do
    @env.stubs(:settings).returns({:google_cse_id => 10})
    assert_equal 10, @plugin.google_id
  end

  should 'not use custom search if google_cse_id isnt set' do
    @env.stubs(:settings).returns({})
    assert_nil @plugin.body_beginning
    @env.stubs(:settings).returns({:google_cse_id => 11})
    assert_not_nil @plugin.body_beginning
  end

end
