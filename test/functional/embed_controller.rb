require File.dirname(__FILE__) + '/../test_helper'

class EmbedControllerTest < ActionController::TestCase

  def setup
    login_as(create_admin_user(Environment.default))
    @block = LoginBlock.create!
    @environment = Environment.default
    @environment.boxes.create!
    @environment.boxes.first.blocks << @block
  end

  should 'be able to get embed block' do
    get :index, :id => @block.id
    assert_tag :tag => 'div', :attributes => { :id => "block-#{@block.id}" }
  end

  should 'display error message when not found block' do
    Block.delete_all
    get :index, :id => 1
    assert_tag :tag => 'div', :attributes => { :id => "not-found" }
  end

  should 'display error message when block is not visible/public' do
    @block.display = 'never'
    @block.save
    get :index, :id => @block.id
    assert_tag :tag => 'div', :attributes => { :id => "not-found" }
  end

end
