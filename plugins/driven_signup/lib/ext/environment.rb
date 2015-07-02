require_dependency 'environment'

class Environment

  has_many :driven_signup_auths, class_name: 'DrivenSignupPlugin::Auth', dependent: :destroy

end
