require_relative "../test_helper"

class SellersSearchBlockTest < ActiveSupport::TestCase

  should 'provide description' do
    assert_not_equal Block.description, SellersSearchBlock.description
  end

  should 'provide default title' do
    assert_not_equal Block.new.default_title, SellersSearchBlock.new.default_title
  end

  should 'not use a fixed title' do
    block = SellersSearchBlock.new(:title => 'my custom title')
    expects(:render).with(:file => 'search/_sellers_form', :locals => { :title => 'my custom title'})
    instance_eval(&block.content)
  end

end
