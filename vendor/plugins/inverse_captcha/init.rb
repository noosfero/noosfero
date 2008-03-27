ActionController::Base.extend(InverseCaptcha::ClassMethods)
ActionController::Base.send(:include, InverseCaptcha::InstanceMethods)
ActionView::Base.send(:include, InverseCaptchaHelper)
