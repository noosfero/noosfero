module InverseCaptchaHelper

  def icaptcha_field(opt = {})
    label = controller.class::ICAPTCHA_LABEL
    field = controller.class::ICAPTCHA_FIELD
    opt.merge!({:class => controller.class::ICAPTCHA_STYLECLASS})
    stylesheet = "<style type='text/css'> span.#{opt[:class]} { display: none; } </style>"
    stylesheet + content_tag('span', labelled_form_field(_(label), text_field_tag(field, nil)), opt)
  end

end
