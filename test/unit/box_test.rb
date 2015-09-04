require_relative "../test_helper"

class BoxTest < ActiveSupport::TestCase

  def setup
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([])
  end

  should 'retrieve environment based on owner' do
    profile = fast_create(Profile)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => 'Profile')
    assert_equal profile.environment, box.environment

    box = fast_create(Box, :owner_id => Environment.default.id, :owner_type => 'Environment')
    assert_equal Environment.default, box.environment
  end

  should 'list allowed blocks for center box' do
    blocks = Box.new.tap { |b| b.position = 1 }.acceptable_blocks

    refute blocks.include?('.block')
    refute blocks.include?('.disabled-enterprise-message-block')
    refute blocks.include?('.featured-products-block')
    refute blocks.include?('.products-block')
    refute blocks.include?('.profile-info-block')
    refute blocks.include?('.profile-list-block')
    refute blocks.include?('.profile-search-block')
    refute blocks.include?('.slideshow-block')
    refute blocks.include?('.location-block')

    assert blocks.include?('.article-block')
    assert blocks.include?('.blog-archives-block')
    assert blocks.include?('.categories-block')
    assert blocks.include?('.communities-block')
    assert blocks.include?('.enterprises-block')
    assert blocks.include?('.fans-block')
    assert blocks.include?('.favorite-enterprises-block')
    assert blocks.include?('.feed-reader-block')
    assert blocks.include?('.highlights-block')
    assert blocks.include?('.link-list-block')
    assert blocks.include?('.login-block')
    assert blocks.include?('.main-block')
    assert blocks.include?('.my-network-block')
    assert blocks.include?('.profile-image-block')
    assert blocks.include?('.raw-html-block')
    assert blocks.include?('.recent-documents-block')
    assert blocks.include?('.sellers-search-block')
    assert blocks.include?('.tags-block')
  end

  should 'list allowed blocks for box at position 2' do
    blocks = Box.new.tap { |b| b.position = 2 }.acceptable_blocks

    refute blocks.include?('.main-block')
    refute blocks.include?('.block')
    refute blocks.include?('.profile-list-block')

    assert blocks.include?('.article-block')
    assert blocks.include?('.blog-archives-block')
    assert blocks.include?('.categories-block')
    assert blocks.include?('.communities-block')
    assert blocks.include?('.disabled-enterprise-message-block')
    assert blocks.include?('.enterprises-block')
    assert blocks.include?('.fans-block')
    assert blocks.include?('.favorite-enterprises-block')
    assert blocks.include?('.featured-products-block')
    assert blocks.include?('.feed-reader-block')
    assert blocks.include?('.highlights-block')
    assert blocks.include?('.link-list-block')
    assert blocks.include?('.location-block')
    assert blocks.include?('.login-block')
    assert blocks.include?('.my-network-block')
    assert blocks.include?('.products-block')
    assert blocks.include?('.profile-image-block')
    assert blocks.include?('.profile-info-block')
    assert blocks.include?('.profile-search-block')
    assert blocks.include?('.raw-html-block')
    assert blocks.include?('.recent-documents-block')
    assert blocks.include?('.sellers-search-block')
    assert blocks.include?('.slideshow-block')
    assert blocks.include?('.tags-block')
  end

  should 'list plugin block as allowed for box at position 1' do
    class SomePlugin < Noosfero::Plugin
      def self.extra_blocks
        { PluginBlock => {:position => 1} }
      end
    end
    class PluginBlock < Block
      def self.to_s; 'plugin-block'; end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    blocks = build(Box, :position => 1).acceptable_blocks
    assert blocks.include?('box-test_plugin-block')
  end

  should 'list plugin block as allowed for box at position 2' do
    class SomePlugin < Noosfero::Plugin
      def self.extra_blocks
        { PluginBlock => {:position => 2} }
      end
    end
    class PluginBlock < Block
      def self.to_s; 'plugin-block'; end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    blocks = build(Box, :position => 2).acceptable_blocks
    assert blocks.include?('box-test_plugin-block')
  end

  should 'list plugin block as allowed for the right holder' do
    class SomePlugin < Noosfero::Plugin
      def self.extra_blocks
        { PluginBlock => {:position => 1, :type => [Person, Enterprise]} }
      end
    end
    class PluginBlock < Block
      def self.to_s; 'plugin-block'; end
    end
    Noosfero::Plugin::Manager.any_instance.stubs(:enabled_plugins).returns([SomePlugin.new])

    blocks = build(Box, :position => 1, :owner => Person.new).acceptable_blocks
    assert blocks.include?('box-test_plugin-block')

    blocks = build(Box, :position => 1, :owner => Enterprise.new).acceptable_blocks
    assert blocks.include?('box-test_plugin-block')

    blocks = build(Box, :position => 1, :owner => Community.new).acceptable_blocks
    refute blocks.include?('box-test_plugin-block')
  end

  should 'list only boxes with a postion greater than zero' do
    profile = fast_create(Profile)
    box = fast_create(Box, :owner_id => profile.id, :owner_type => 'Profile', :position => 0)
    box2 = fast_create(Box, :owner_id => profile.id, :owner_type => 'Profile', :position => 1)
    assert_equal [box2], profile.boxes.with_position
  end

end
