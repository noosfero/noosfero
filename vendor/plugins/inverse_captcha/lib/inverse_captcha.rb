module InverseCaptcha

  module ClassMethods
    def inverse_captcha(opt = {})
      InverseCaptcha.const_set("ICAPTCHA_FIELD", opt[:field])
      InverseCaptcha.const_set("ICAPTCHA_LABEL", opt[:label] || N_("Don't fill this field"))
      InverseCaptcha.const_set("ICAPTCHA_STYLECLASS", opt[:class] || 'ghost')
      self.send(:include, InverseCaptcha)
    end
  end

  module InstanceMethods 
    def icaptcha_field
      ICAPTCHA_FIELD
    end
  end

end
