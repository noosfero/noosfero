require_relative "../test_helper"

class PluginHotSpotTest < ActiveSupport::TestCase

  class Client
    include Noosfero::Plugin::HotSpot
  end

  def setup
    @client = Client.new
    @client.stubs(:environment).returns(Environment.new)
  end

  should 'instantiate only once' do
    assert_same @client.plugins, @client.plugins
  end

  Noosfero::Plugin::HotSpot::CALLBACK_HOTSPOTS.each do |callback|
    should "call #{callback} hotspot" do
      class CoolPlugin < Noosfero::Plugin; end

      Noosfero::Plugin.stubs(:all).returns([CoolPlugin.name])
      Environment.default.enable_plugin(CoolPlugin)
      CoolPlugin.any_instance.expects("comment_#{callback}_callback".to_sym)

      person = fast_create(Person)
      article = fast_create(Article, :profile_id => person.id)
      comment = Comment.create!(:author => person, :title => 'test comment', :body => 'body!', :source => article)
      comment.destroy
    end
  end

end
