if ENV['MAILGUN_TOKEN'].present?
  # Use with mailgun-ruby or mailgun_rails gem

  ActionMailer::Base.delivery_method  = :mailgun
  ActionMailer::Base.mailgun_settings = {
    api_key: ENV['MAILGUN_TOKEN'],
    domain:  ENV['MAILGUN_DOMAIN'],
  }
end
