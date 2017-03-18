# FIXME: this tests must me moved into design plugin

require_relative '../test_helper'

class EditTemplateControllerTest < ActionController::TestCase
  all_fixtures
  def setup
    @controller = EditTemplateController.new

    login_as 'ze'
  end

  def test_redirect_to_design_editor_when_index_action_is_called
    give_permission('ze', 'edit_environment_design', Environment.default)
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'design_editor'
  end

  #############################################################
  # FIXME: design_editor stuff, move to design plugin
  #############################################################

end
