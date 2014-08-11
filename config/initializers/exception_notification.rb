unless NOOSFERO_CONF['exception_recipients'].blank?
  Noosfero::Application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :sender_address => "noreply@#{Noosfero.default_hostname}",
      :email_prefix => "[Noosfero ERROR] ",
      :exception_recipients => NOOSFERO_CONF['exception_recipients']
    }
end
