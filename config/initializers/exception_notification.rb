unless NOOSFERO_CONF['exception_recipients'].blank?
  require 'exception_notification.rb'
  ExceptionNotifier.sender_address = "noreply@#{Noosfero.default_hostname}"
  ExceptionNotifier.email_prefix = "[Noosfero ERROR] "
  ExceptionNotifier.exception_recipients = NOOSFERO_CONF['exception_recipients']
  ActionController::Base.send :include, ExceptionNotifiable
end
