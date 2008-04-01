module InverseCaptcha

  module ClassMethods
    def inverse_captcha(opt = {})
      InverseCaptcha.const_set("ICAPTCHA_FIELD", opt[:field]) unless InverseCaptcha.const_defined? "ICAPTCHA_FIELD"
      InverseCaptcha.const_set("ICAPTCHA_LABEL", opt[:label] || N_("Don't fill this field")) unless InverseCaptcha.const_defined? "ICAPTCHA_LABEL"
      InverseCaptcha.const_set("ICAPTCHA_STYLECLASS", opt[:class] || 'ghost') unless InverseCaptcha.const_defined? "ICAPTCHA_STYLECLASS"
      self.send(:include, InverseCaptcha)
    end
  end

  module InstanceMethods 
    def icaptcha_field
      ICAPTCHA_FIELD
    end
  end

end
