if ENV['ROLLBAR_TOKEN'].present?
  Rollbar.configure do |config|
    config.access_token = ENV['ROLLBAR_TOKEN']

    config.exception_level_filters.merge!(
      'ActionController::InvalidCrossOriginRequest' => 'ignore',
    )

    config.before_process << proc do |options|
      agent = options[:scope][:request][:headers]['User-Agent']
      raise Rollbar::Ignore if Browser.new(agent).bot?
    end if defined? Browser
  end
end

