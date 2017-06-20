require 'test_helper'

class ThemeManagerHelperPluginTest < ActiveSupport::TestCase

  _dir = File.dirname(__FILE__)
  require 'fileutils'
  require File.join _dir, '../../helpers/theme_manager_helper'

  def fixture(name)
    File.join File.dirname(__FILE__), '..', 'fixture', name
  end

  include ThemeManagerHelper

  def setup
    @temp = Dir.mktmpdir 'noosfero-theme-manager-plugin-test'
  end

  def teardown
    FileUtils.rm_rf @temp
  end

  should "identify uploaded package file temp" do
    pack = mock
    pack.stubs(:read).returns 'this is a test'
    result = get_theme_package @temp, pack
    assert_equal result[:file_type], 'text/plain'
    pack.stubs(:read).returns 'PKJteste/PK'
    result = get_theme_package @temp, pack
    assert_equal result[:file_type], 'application/zip'
  end

  should "exists zipfile reference" do
    pack = mock
    pack.stubs(:read).returns 'this is a test'
    result = get_theme_package @temp, pack
    assert File.exists? result[:zip]
    assert_equal 'this is a test', File.read(result[:zip])
  end

  should "unzip to existing destination" do
    unzip_file fixture('test-with-yml.zip'), @temp
    assert File.exists? File.join(@temp, 'test/theme.yml')
  end

  should "unzip to new destination" do
    unzip_file fixture('test-with-yml.zip'), @temp+'/somewhere'
    assert File.exists? File.join(@temp, 'somewhere/test/theme.yml')
  end

  should "return theme name on validation of a valid theme" do
    unzip_file fixture('test-with-yml.zip'), @temp
    response = validate_theme_files File.join(@temp, 'test')
    refute response[:error]
    assert_equal 'My Theme', response[:name]
  end

  should "return error on validation of a non valid theme" do
    unzip_file fixture('test-no-yml.zip'), @temp
    response = validate_theme_files @temp
    refute response[:name]
    assert response[:error]
  end

  should "find the yml in root" do
    theme_dir = File.join @temp, 'test'
    unzip_file fixture('test-with-yml.zip'), @temp
    dir_yml = find_theme_root theme_dir
    assert_equal dir_yml, theme_dir
  end

  should "find the yml directory" do
    unzip_file fixture('test-with-yml.zip'), @temp
    dir_yml = find_theme_root @temp
    assert_equal dir_yml, File.join(@temp, 'test')
  end

  should "find the yml directory in subdirectories" do
    base_dir = File.join @temp, 'sub-test'
    unzip_file fixture('test-with-yml.zip'), base_dir
    dir_yml = find_theme_root @temp
    assert_equal dir_yml, File.join(base_dir, 'test')
  end

  def stubs_cp_r &blok
    FileUtils.class_eval { @cp_r = self.method :cp_r }
    $_stubs_cp_r_block = blok
    def FileUtils.cp_r(from, to)
      $_stubs_cp_r_block.call from, to
    end
  end

  def unstubs_cp_r
    FileUtils.class_eval { def self.cp_r(f,t); @cp_r.call f,t; end }
  end

  should "activate theme" do
    env = mock
    env.stubs(:add_themes)
    env.stubs(:save!)
    stubs_cp_r do |from, to|
      unless 'public/designs/themes/my-theme' == to
        throw 'the destination dir is wrong'
      end
    end
    sucess, error = activate_theme '/some/where', 'My Theme', env
    unstubs_cp_r
    error_msg = error ? error.message : 'unknown error'
    assert sucess, error_msg
    refute error, error_msg
  end

  should "get copy fail on activate theme" do
    env = mock
    env.stubs(:add_themes)
    env.stubs(:save!)
    stubs_cp_r do |from, to|
      throw 'Simulate FS trouble'
    end
    sucess, error = activate_theme '/some/where', 'My Theme', env
    unstubs_cp_r
    error_msg = error ? error.message : 'unknown error'
    refute sucess, error_msg
    assert_equal 'uncaught throw "Simulate FS trouble"', error.message
  end

  should "get env.save! fail on activate theme" do
    env = mock
    env.stubs(:add_themes)
    env.stubs(:save!).throws "Simulate env.save! fail"
    stubs_cp_r { }
    sucess, error = activate_theme '/some/where', 'My Theme', env
    unstubs_cp_r
    error_msg = error ? error.message : 'unknown error'
    refute sucess, error_msg
    assert_equal 'uncaught throw "Simulate env.save! fail"', error.message
  end

end
