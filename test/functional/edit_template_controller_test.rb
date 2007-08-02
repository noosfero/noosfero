# FIXME: this tests must me moved into design plugin

require File.dirname(__FILE__) + '/../test_helper'
require 'edit_template_controller'

# Re-raise errors caught by the controller.
class EditTemplateController; def rescue_action(e) raise e end; end

class EditTemplateControllerTest < Test::Unit::TestCase

  def setup
    @controller = EditTemplateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_redirect_to_design_editoe_when_index_action_is_called
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
  end

end
