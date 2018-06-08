Recaptcha.configure do |config|
  config.site_key   = NOOSFERO_CONF['api_recaptcha_site_key'] || '6LcK7CYUAAAAABl-eMkoFIv3VvOOIPwiXeinFmUi'
  config.secret_key = NOOSFERO_CONF['api_recaptcha_private_key'] || '6LcK7CYUAAAAAN-oooxubQRkDEf_EKqygh4Hs3CB'
end
