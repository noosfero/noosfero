require_relative "../test_helper"

class EmbedControllerTest < ActionController::TestCase

  def setup
    login_as(create_admin_user(Environment.default))
    @block = LoginBlock.create!
    @block.class.any_instance.stubs(:embedable?).returns(true)
    @environment = Environment.default
    @environment.boxes.create!
    @environment.boxes.first.blocks << @block
  end

  should 'be able to get embed block' do
    get :block, :id => @block.id
    assert_tag :tag => 'div', :attributes => { :id => "block-#{@block.id}" }
  end

  should 'display error message when not found block' do
    Block.delete_all
    get :block, :id => 1
    assert_tag :tag => 'div', :attributes => { :id => "not-found" }
  end

  should 'display error message when block is not visible/public' do
    @block.display = 'never'
    assert @block.save
    get :block, :id => @block.id
    assert_tag :tag => 'div', :attributes => { :id => "unavailable" }
  end

  should 'display error message when block is not embedable' do
    @block.class.any_instance.stubs(:embedable?).returns(false)
    get :block, :id => @block.id
    assert_tag :tag => 'div', :attributes => { :id => "unavailable" }
  end


end
