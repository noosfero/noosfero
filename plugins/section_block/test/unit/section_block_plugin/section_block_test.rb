require 'test_helper'

class SectionBlockPlugin::SectionBlockTest < ActiveSupport::TestCase

  def setup
    @block = SectionBlockPlugin::SectionBlock.new
    @block.stubs(:owner).returns(Environment.default)
  end

  should 'describe yourself' do
    refute SectionBlockPlugin::SectionBlock.description.blank?
  end

  should 'has a help' do
    refute @block.help.blank?
  end

  should 'have a default name' do
    @block.save!
    refute @block.name.blank?
  end

  should 'have a default font color' do
    @block.save!
    refute @block.font_color.blank?
  end

  should 'have a default background color' do
    @block.save!
    refute @block.background_color.blank?
  end

  should 'raise exception while trying to save empty name' do
    @block.name = ''
    assert_raise ActiveRecord::RecordInvalid do
      @block.save!
    end
  end

  should 'not be cacheable' do
    @block.save!
    assert_equal false, @block.cacheable?
  end

  should 'contain font color on css inline style' do
    @block.save!
    assert_match 'color: ', @block.css_inline_style
  end

  should 'contain background color on css inline style' do
    @block.save!
    assert_match 'background-color: ', @block.css_inline_style
  end

  should 'normalize colors on save block' do
    @block.font_color = '#FFFFFF'
    @block.background_color = "#000000"
    @block.save!
    assert_equal 'FFFFFF', @block.font_color
    assert_equal '000000', @block.background_color
  end

end
