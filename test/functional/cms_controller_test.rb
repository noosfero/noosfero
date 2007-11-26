require File.dirname(__FILE__) + '/../test_helper'
require 'cms_controller'

# Re-raise errors caught by the controller.
class CmsController; def rescue_action(e) raise e end; end

class CmsControllerTest < Test::Unit::TestCase
  def setup
    @controller = CmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  attr_reader :profile

  should 'list top level documents on index' do
    flunk 'not yet'
  end

  should 'be able to view a particular document' do
    flunk 'not yet'
  end

  should 'be able to edit a document' do
    flunk 'not yet'
  end

  should 'be able to save a save a document' do
    flunk 'not yet'
  end

end
