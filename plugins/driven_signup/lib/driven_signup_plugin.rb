module DrivenSignupPlugin

  extend Noosfero::Plugin::ParentMethods

  def self.plugin_name
    _'Driven signup'
  end

  def self.plugin_description
    _'Allow external websites to manage the signup'
  end

end
