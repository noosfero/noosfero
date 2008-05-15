require File.dirname(__FILE__) + '/../test_helper'

class ActsAsHavingSettingsTest < Test::Unit::TestCase

  # using Block class as a sample user of the module 

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
    klass = Class.new(Block)
    klass.settings_items :flag, :default => true
    obj = klass.new
    obj.flag = false
    assert_equal false, obj.flag
  end

end
