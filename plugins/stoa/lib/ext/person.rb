require_dependency 'person'

class Person
  validates_uniqueness_of :usp_id, :allow_nil => true
  settings_items :invitation_code
  validate :usp_id_or_invitation, :if => lambda { |person| person.environment && person.environment.plugin_enabled?(StoaPlugin)}

  def usp_id_or_invitation
    if usp_id.blank? && (invitation_code.blank? || !Task.pending.find(:first, :conditions => {:code => invitation_code}))
      errors.add(:usp_id, "can't register without usp_id or invitation")
    end
  end
end
