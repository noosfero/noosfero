class CaptchaController < AdminController
  protect 'manage_environment_captcha', :environment

  def index
    if request.post?
      environment.metadata['captcha'] = params['captcha']
      environment.save!
    end
  end
end
