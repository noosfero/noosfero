require 'test_helper'

class EnvironmentTest < ActiveSupport::TestCase

  def setup
    @env = Environment.default
  end

  should 'save data with plugin namespace' do
    @env.custom_forms_plugin_metadata['max_csv_size'] = 5.megabytes
    assert_equal({ 'max_csv_size' => 5.megabytes },
                 @env.metadata['custom_forms_plugin'])
  end

  should 'return default value if config is not set' do
    assert_equal Environment::DEFAULT_CSV_MAX_SIZE,
                 @env.submissions_csv_max_size
  end

  should 'return custom value if config is set' do
    @env.custom_forms_plugin_metadata['max_csv_size'] = 5.megabytes
    assert_equal 5.megabytes, @env.submissions_csv_max_size
  end

end
