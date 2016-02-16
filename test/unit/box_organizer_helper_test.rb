# encoding: UTF-8
require File.dirname(__FILE__) + '/../test_helper'

class BoxOrganizerHelperTest < ActionView::TestCase


  def setup
    @environment = Environment.default
  end

  attr_reader :environment

  should 'display the default icon for block without icon' do
    class SomeBlock < Block; end
    block = SomeBlock
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)
    assert_match '/images/icon_block.png', display_icon(block)
  end

  should 'display the icon block' do
    class SomeBlock < Block; end
    block = SomeBlock
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'images', '/blocks/some_block/icon.png')).returns(true)
    assert_match 'blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the plugin icon block' do
    class SomeBlock < Block; end
    block = SomeBlock
    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'plugins/some/images/blocks/some_block/icon.png')).returns(true)
    assert_match 'plugins/some/images/blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the theme icon block' do
    class SomeBlock < Block; end
    block = SomeBlock

    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'designs/themes/some_theme/images/blocks/some_block/icon.png')).returns(true)
    assert_match 'designs/themes/some_theme/images/blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the theme icon block instead of block icon' do
    class SomeBlock < Block; end
    block = SomeBlock

    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'designs/themes/some_theme/images/blocks/some_block/icon.png')).returns(true)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'images', '/blocks/some_block/icon.png')).returns(true)
    assert_match 'designs/themes/some_theme/images/blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the theme icon block instead of plugin block icon' do
    class SomeBlock < Block; end
    block = SomeBlock

    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)

    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'designs/themes/some_theme/images/blocks/some_block/icon.png')).returns(true)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'plugins/some/images/blocks/some_block/icon.png')).returns(true)
    assert_match 'designs/themes/some_theme/images/blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the theme icon block instead of block icon and plugin icon' do
    class SomeBlock < Block; end
    block = SomeBlock

    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)


    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'designs/themes/some_theme/images/blocks/some_block/icon.png')).returns(true)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'plugins/some/images/blocks/some_block/icon.png')).returns(true)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'images', '/blocks/some_block/icon.png')).returns(true)
    assert_match 'designs/themes/some_theme/images/blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the plugin icon block instead of block icon' do
    class SomeBlock < Block; end
    block = SomeBlock

    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)


    File.stubs(:exists?).returns(false)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'plugins/some/images/blocks/some_block/icon.png')).returns(true)
    File.stubs(:exists?).with(File.join(Rails.root, 'public', 'images', '/blocks/some_block/icon.png')).returns(true)
    assert_match 'plugins/some/images/blocks/some_block/icon.png', display_icon(block)
  end

  should 'display the default preview for block without previews images' do
    class SomeBlock < Block; end
    block = SomeBlock
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/images\/block_preview.png.*"/, elements[0].to_s
      assert_match /img.* src="\/images\/block_preview.png.*"/, elements[1].to_s
      assert_match /img.* src="\/images\/block_preview.png.*"/, elements[2].to_s
    end
  end

  should 'display the previews of block' do
    class SomeBlock < Block; end
    block = SomeBlock
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])
    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end
  end

  should 'display the plugin preview images of block' do
    class SomeBlock < Block; end
    block = SomeBlock
    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)


    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'plugins/some/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])
    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/plugins\/some\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/plugins\/some\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end

  end

  should 'display the theme previews of block' do
    class SomeBlock < Block; end
    block = SomeBlock

    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    @environment = mock
    @environment.stubs(:theme).returns('some_theme')


    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'designs/themes/some_theme/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])
    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end

  end

  should 'display the theme preview images of block instead of block preview images' do
    class SomeBlock < Block; end
    block = SomeBlock

    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(nil)

    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'designs/themes/some_theme/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    base_path = File.join(Rails.root, 'public', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end
  end

  should 'display the theme preview images of block instead of plugin preview images' do
    class SomeBlock < Block; end
    block = SomeBlock

    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)

    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'designs/themes/some_theme/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    base_path = File.join(Rails.root, 'public', 'plugins/some/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end

  end

  should 'display the theme preview images of block instead of block previews and plugin previews' do
    class SomeBlock < Block; end
    block = SomeBlock

    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)


    @environment = mock
    @environment.stubs(:theme).returns('some_theme')

    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'designs/themes/some_theme/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    base_path = File.join(Rails.root, 'public', 'plugins/some/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    base_path = File.join(Rails.root, 'public', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/designs\/themes\/some_theme\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end

  end

  should 'display the plugin preview images of block instead of block previews' do
    class SomeBlock < Block; end
    block = SomeBlock

    class SomePlugin < Noosfero::Plugin; end
    SomePlugin.stubs(:name).returns('SomePlugin')
    @plugins = mock
    @plugins.stubs(:fetch_first_plugin).with(:has_block?, block).returns(SomePlugin)

    Dir.stubs(:glob).returns([])
    base_path = File.join(Rails.root, 'public', 'designs/themes/some_theme/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    base_path = File.join(Rails.root, 'public', 'plugins/some/', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    base_path = File.join(Rails.root, 'public', 'images', '/blocks/some_block/previews/')
    Dir.stubs(:glob).with(File.join(base_path, '*')).returns([File.join(base_path, 'p1.png'), File.join(base_path, 'p2.png')])

    doc = Nokogiri::HTML display_previews(block)
    assert_select doc, 'li' do |elements|
      assert_match /img.* src="\/plugins\/some\/images\/blocks\/some_block\/previews\/p1.png"/, elements[0].to_s
      assert_match /img.* src="\/plugins\/some\/images\/blocks\/some_block\/previews\/p2.png"/, elements[1].to_s
    end

  end


end
