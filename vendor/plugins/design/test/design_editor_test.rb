require File.join(File.dirname(__FILE__), 'test_helper')

class DesignEditorTest < Test::Unit::TestCase

  def setup
    @controller = DesignHelperTestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    Design.public_filesystem_root = File.join(File.dirname(__FILE__))
  end

  def teardown
    Design.public_filesystem_root = nil
  end

end
