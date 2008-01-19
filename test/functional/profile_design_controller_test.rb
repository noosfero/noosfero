require File.dirname(__FILE__) + '/../test_helper'
require 'profile_design_controller'

class ProfileDesignController; def rescue_action(e) raise e end; end

class ProfileDesignControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = ProfileDesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    holder = create_user('designtestuser').person
    holder.save!
 
    @box1 = Box.new
    @box2 = Box.new
    @box3 = Box.new

    holder.boxes << @box1
    holder.boxes << @box2
    holder.boxes << @box3

    ###### BOX 1
    @b1 = ArticleBlock.new
    @box1.blocks << @b1
    @b1.save!

    @b2 = Block.new
    @box1.blocks << @b2
    @b2.save!
    
    ###### BOX 2
    @b3 = Block.new
    @box2.blocks << @b3
    @b3.save!

    @b4 = MainBlock.new
    @box2.blocks << @b4
    @b4.save!

    @b5 = Block.new
    @box2.blocks << @b5
    @b5.save!

    @b6 = Block.new
    @box2.blocks << @b6
    @b6.save!
    
    ###### BOX 3
    @b7 = Block.new
    @box3.blocks << @b7
    @b7.save!

    @b8 = Block.new
    @box3.blocks << @b8
    @b8.save!

    @request.env['HTTP_REFERER'] = '/editor'

    @controller.stubs(:boxes_holder).returns(holder)
  end

  ######################################################
  # BEGIN - tests for BoxOrganizerController features 
  ######################################################
  def test_should_move_block_to_the_end_of_another_block
    get :move_block, :profile => 'ze', :id => "block-#{@b1.id}", :target => "end-of-box-#{@box2.id}"

    assert_response :success

    @b1.reload
    @box2.reload

    assert_equal @box2, @b1.box
    assert @b1.in_list?
    assert_equal @box2.blocks.size, @b1.position # i.e. assert @b1.last?
  end

  def test_should_move_block_to_the_middle_of_another_block
    # block 4 is in box 2
    get :move_block, :profile => 'ze', :id => "block-#{@b1.id}", :target => "before-block-#{@b4.id}"

    assert_response :success

    @b1.reload
    @b4.reload

    assert_equal @b4.box, @b1.box
    assert @b1.in_list?
    assert_equal @b4.position - 1, @b1.position
  end

  def test_block_can_be_moved_up
    get :move_block, :profile => 'ze', :id => "block-#{@b4.id}", :target => "before-block-#{@b3.id}"

    assert_response :success
    @b4.reload
    @b3.reload

    assert_equal @b3.position - 1, @b4.position
  end

  def test_block_can_be_moved_down
    assert_equal [1,2,3], [@b3,@b4,@b5].map {|item| item.position}

    # b3 -> before b5
    get :move_block, :profile => 'ze', :id => "block-#{@b3.id}", :target => "before-block-#{@b5.id}"

    [@b3,@b4,@b5].each do |item|
      item.reload
    end

    assert_equal [1,2,3],  [@b4, @b3, @b5].map {|item| item.position}
  end

  def test_should_be_able_to_move_block_directly_down
    post :move_block_down, :profile => 'ze', :id => @b1.id
    assert_response :redirect

    @b1.reload
    @b2.reload

    assert_equal [1,2], [@b2,@b1].map {|item| item.position}
  end

  def test_should_be_able_to_move_block_directly_up
    post :move_block_up, :profile => 'ze', :id => @b2.id
    assert_response :redirect

    @b1.reload
    @b2.reload

    assert_equal [1,2], [@b2,@b1].map {|item| item.position}
  end

  ######################################################
  # END - tests for BoxOrganizerController features 
  ######################################################

  ######################################################
  # BEGIN - tests for ProfileDesignController features 
  ######################################################

  should 'display popup for adding a new block' do
    get :add_block, :profile => 'ze'
    assert_response :success
    assert_no_tag :tag => 'body' # e.g. no layout
  end

  should 'actually add a new block' do
    assert_difference Block, :count do
      post :add_block, :profile => 'ze', :box_id => 1, :type => Block.name
      assert_redirected_to :action => 'index'
    end
  end

  should 'not allow tp create unknown types' do
    assert_no_difference Block, :count do
      assert_raise ArgumentError do
        post :add_block, :profile => 'ze', :box_id => 1, :type => "PleaseLetMeCrackYourSite"
      end
    end
  end

  should 'provide edit screen for blocks' do
    get :edit, :profile => 'ze', :id => @b1.id
    assert_template 'edit'
    assert_no_tag :tag => 'body' # e.g. no layout
  end

  should 'be able to save a block' do
    post :save, :profile => 'ze', :id => @b1.id, :block => { :article_id => 999 }

    assert_redirected_to :action => 'index'

    @b1.reload
    assert_equal 999, @b1.article_id
  end


end

