if ENV['ROLLBAR_TOKEN'].present?
  Rollbar.configure do |config|
    config.access_token = ENV['ROLLBAR_TOKEN']
    config.exception_level_filters.merge!(
      'ActionController::InvalidCrossOriginRequest' => 'ignore',
    )
  end
end
