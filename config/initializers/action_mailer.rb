# Turn off auto TLS for e-mail
ActionMailer::Base.smtp_settings[:enable_starttls_auto] = false
