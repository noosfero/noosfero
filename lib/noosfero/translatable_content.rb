module Noosfero::TranslatableContent

  def translatable?
    return false if self.profile && !self.profile.environment.languages.present?
    parent.nil? || !parent.forum?
  end
end
