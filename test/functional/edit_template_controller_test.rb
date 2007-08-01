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

  def test
    flunk 'FIXME: nothing tested yet'
  end

end
