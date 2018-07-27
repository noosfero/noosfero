module Entitlement::EnvironmentJudge
  include Entitlement::Judge

  def checks
    @checks ||= [
      Entitlement::Checks::Visitor.new,
      Entitlement::Checks::User.new,
    ]
  end

  def captcha_requirement(action)
    level = get_captcha_level(action)
    convert_slider_to_default_level(level).to_i
  end
end
