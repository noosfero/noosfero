require_relative "../test_helper"

class ActsAsHavingSettingsTest < ActiveSupport::TestCase

  # using Block class as a sample user of the module 
  class TestClass < Block
    settings_items :flag, :type => :boolean
    settings_items :flag_disabled_by_default, :type => :boolean, :default => false
    settings_items :name, :type => :string, :default => N_('ENGLISH TEXT')
    attr_accessible :flag, :name, :flag_disabled_by_default
  end

  should 'store settings in a hash' do
    block = Block.new

    assert_kind_of Hash, block.settings
    block.save!

    assert_kind_of Hash, Block.find(block.id).settings
  end

  should 'be able to declare settings items' do
    block_class = Class.new(Block)

    block = block_class.new
    assert !block.respond_to?(:limit)
    assert !block.respond_to?(:limit=)

    block_class.settings_items :limit

    assert_respond_to block, :limit
    assert_respond_to block, :limit=

    assert_nil block.limit
    block.limit = 10
    assert_equal 10, block.limit

    assert_equal({ :limit => 10}, block.settings)
  end

  should 'properly save the settings' do
    # RecentDocumentsBlock declares an actual setting called limit
    profile = create_user('testuser').person
    block = RecentDocumentsBlock.new
    block.box = profile.boxes.first
    block.limit = 15
    block.save!
    assert_equal 15, Block.find(block.id).limit
  end

  should 'be able to specify default values' do
    block_class = Class.new(Block)
    block_class.settings_items :some_setting, :default => 10
    assert_equal 10, block_class.new.some_setting
  end

  should 'be able to set boolean attributes to false with a default of true' do
    obj = TestClass.new
    obj.flag = false
    assert_equal false, obj.flag
  end

  should 'return false by default when the default is false' do
    assert_equal false, TestClass.new.flag_disabled_by_default
  end

  should 'translate default values' do
    TestClass.any_instance.expects(:gettext).with('ENGLISH TEXT').returns("TRANSLATED")
    assert_equal 'TRANSLATED', TestClass.new.name
  end

  should 'be able to specify type of atrributes (boolean)' do
    obj = TestClass.new
    obj.flag = 'true'
    assert_equal true, obj.flag
  end

  should 'symbolize keys when save' do
    obj = TestClass.new
    obj.settings.expects(:symbolize_keys!).once
    assert obj.save
  end

  should 'setting_changed be true if a setting passed as parameter was changed' do
    obj = TestClass.new
    obj.flag = true
    assert obj.setting_changed? 'flag'
  end

  should 'setting_changed be false if a setting passed as parameter was not changed' do
    obj = TestClass.new
    assert !obj.setting_changed?('flag')
  end

  should 'setting_changed be false if a setting passed as parameter was changed with the same value' do
    obj = TestClass.new
    obj.flag = true
    obj.save
    obj.flag = true
    assert !obj.setting_changed?('flag')
  end

  should 'setting_changed be false if a setting passed as parameter was not changed but another setting is changed' do
    obj = TestClass.new(:name => 'some name')
    obj.save
    obj.name = 'antoher nme'
    assert !obj.setting_changed?('flag')
  end

  should 'setting_changed be true for all changed fields' do
    obj = TestClass.new(:name => 'some name', :flag => false)
    obj.save
    obj.name = 'another nme'
    obj.flag = true
    assert obj.setting_changed?('flag')
    assert obj.setting_changed?('name')
  end
end
