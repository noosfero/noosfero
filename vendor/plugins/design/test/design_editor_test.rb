require File.join(File.dirname(__FILE__), 'test_helper')

class DesignEditorTest < Test::Unit::TestCase

  def setup
    @controller = DesignEditorTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end

  def teardown
    Design.public_filesystem_root = nil
  end

  def test_should_render_design_in_editor_mode
    get :design_editor
    assert_response :success
    assert_template 'design_editor'
  end

  def test_should_set_new_template
    assert_equal 'default', @controller.send(:design).template
    post :design_editor, :template => 'empty'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'empty', @controller.send(:design).template
    assert @controller.send(:design).saved?
  end

  def test_should_not_set_to_unexisting_template
    assert_equal 'default', @controller.send(:design).template
    post :design_editor, :template => 'no_existing_template'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'default', @controller.send(:design).template
    assert @controller.send(:design).saved?
  end


  def test_should_set_new_theme
    assert_equal 'default', @controller.send(:design).theme
    post :design_editor, :theme => 'empty'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'empty', @controller.send(:design).theme
    assert @controller.send(:design).saved?
  end

  def test_should_not_set_to_unexisting_theme
    assert_equal 'default', @controller.send(:design).theme
    post :design_editor, :theme => 'no_existing_theme'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'default', @controller.send(:design).theme
    assert @controller.send(:design).saved?
  end

  def test_should_set_new_icon_theme
    assert_equal 'default', @controller.send(:design).icon_theme
    post :design_editor, :icon_theme => 'empty'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'empty', @controller.send(:design).icon_theme
    assert @controller.send(:design).saved?
  end

  def test_should_not_set_to_unexisting_icon_theme
    assert_equal 'default', @controller.send(:design).icon_theme
    post :design_editor, :icon_theme => 'no_existing_icon_theme'
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
    assert_equal 'default', @controller.send(:design).icon_theme
    assert @controller.send(:design).saved?
  end

end
