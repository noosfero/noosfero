require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < ActiveSupport::TestCase

  TMP_THEMES_DIR = RAILS_ROOT + '/test/tmp/themes'

  def setup
    Theme.stubs(:user_themes_dir).returns(TMP_THEMES_DIR)
  end

  def teardown
    FileUtils.rm_rf(TMP_THEMES_DIR)
  end

  should 'list system themes' do
    Dir.expects(:glob).with(RAILS_ROOT + '/public/designs/themes/*').returns(
      [
        RAILS_ROOT + '/public/designs/themes/themeone',
        RAILS_ROOT + '/public/designs/themes/themetwo',
        RAILS_ROOT + '/public/designs/themes/themethree'
    ])

    assert_equal ['themeone', 'themetwo', 'themethree'], Theme.system_themes.map(&:id)
  end

  should 'use id as name by default' do
    assert_equal 'the-id', Theme.new('the-id').name
  end

  should 'create theme' do
    t = Theme.create('mytheme')
    assert_equal t, Theme.find('mytheme')
  end

  should 'not be able to create two themes with the same identifier' do
    Theme.create('themeid')
    assert_raise Theme::DuplicatedIdentifier do
      Theme.create('themeid')
    end
  end

  should 'not be able to create a theme named after a system theme' do
    Theme.expects(:system_themes).returns([Theme.new('somesystemtheme')])
    assert_raise Theme::DuplicatedIdentifier do
      Theme.create('somesystemtheme')
    end
  end

  should 'be able to add new CSS file to theme' do
    t = Theme.create('mytheme')
    t.add_css('common.css')
    assert_equal '', File.read(TMP_THEMES_DIR + '/mytheme/stylesheets/common.css')
  end

  should 'be able to update CSS file' do
    t = Theme.create('mytheme')
    t.add_css('common.css')
    t.update_css('common.css', '/* only a comment */')
    assert_equal '/* only a comment */', File.read(TMP_THEMES_DIR + '/mytheme/stylesheets/common.css')
  end

  should 'be able to get content of CSS file' do
    t = Theme.create('mytheme')
    t.update_css('common.css', '/* only a comment */')
    assert_equal '/* only a comment */', t.read_css('common.css')
  end

  should 'force .css suffix for CSS files when adding' do
    t = Theme.create('mytheme')
    t.add_css('xyz')
    assert_includes t.css_files, 'xyz.css'
  end

  should 'list CSS files' do
    t = Theme.create('mytheme')
    t.add_css('one.css')
    t.add_css('two.css')
    assert_includes t.css_files, 'one.css'
    assert_includes t.css_files, 'two.css'
  end

  should 'add default stylesheets' do
    theme = Theme.create('test')
    %w[ common help menu article button search blocks forms login-box ].each do |item|
      assert_includes theme.css_files, item + '.css'
    end
  end

  should 'be able to save twice' do
    t = Theme.new('testtheme')

    assert_nothing_raised do
      t.save
      t.save
    end
  end

  should 'have an owner' do
    profile = create_user('testinguser').person
    t = Theme.new('mytheme')
    t.owner = profile
    t.save

    t = Theme.find('mytheme')
    assert_equal profile, t.owner
  end

  should 'have no owner by default' do
    assert_nil Theme.new('test').owner
  end

  should 'be able to find by owner' do
    profile = create_user('testinguser').person
    t = Theme.new('mytheme')
    t.owner = profile
    t.save

    assert_equal [t], Theme.find_by_owner(profile)
  end

  should 'be able to set attributes in constructor' do
    p = create_user('testuser').person
    assert_equal p, Theme.new('test', :owner => p).owner
  end

  should 'pass attributes to constructor' do
    p = create_user('testuser').person
    assert_equal p, Theme.create('test', :owner => p).owner
  end

  should 'have a name' do
    theme = Theme.new('mytheme', :name => 'My Theme')
    assert_equal 'My Theme', theme.name
    assert_equal 'My Theme', theme.config['name']
  end

  should 'insert image' do
    theme = Theme.create('mytheme')
    theme.add_image('test.png', 'FAKE IMAGE DATA')

    assert_equal 'FAKE IMAGE DATA', File.read(TMP_THEMES_DIR + '/mytheme/images/test.png')
  end

  should 'list images' do
    theme = Theme.create('mytheme')
    theme.add_image('one.png', 'FAKE IMAGE DATA')
    theme.add_image('two.png', 'FAKE IMAGE DATA')

    assert_equivalent [ 'one.png', 'two.png' ], theme.image_files
  end

  should 'be able to find public themes' do
    profile = create_user('testinguser').person
    t1 = Theme.create('mytheme', :owner => profile, :public => false)
    t2 = Theme.create('mytheme2', :owner => profile, :public => true)

    assert_equal [t2], Theme.public_themes
  end

  should 'set theme to public' do
    t = Theme.new('mytheme')
    t.public = true
    t.save

    t = Theme.find('mytheme')
    assert t.public
  end

  should 'not be public by default' do
    assert ! Theme.new('test').public
  end

end

