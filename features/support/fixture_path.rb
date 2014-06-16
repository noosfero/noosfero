module FixturePathHelper
  def (ActionDispatch::Integration::Session).fixture_path
    ActionController::TestCase.fixture_path
  end
end
