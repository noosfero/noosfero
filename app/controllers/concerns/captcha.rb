module Captcha
  def verify_captcha(action, model, user, environment, profile = nil, message = _('Make sure you made the test to verify that your are not a robot!'))
    environment.require_captcha?(action, user, profile) ? verify_recaptcha(model:  model, message: message) : true
  end
end
