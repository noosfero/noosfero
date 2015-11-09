require_dependency 'person'

class Person
  attr_accessible :usp_id, :invitation_code

  SEARCHABLE_FIELDS[:usp_id] = {:label => _('USP Number'), :weight => 5}

  validates_uniqueness_of :usp_id, :allow_nil => true
  settings_items :invitation_code
  validate :usp_id_or_invitation, :if => lambda { |person| person.environment && person.environment.plugin_enabled?(StoaPlugin)}

  before_validation do |person|
    person.usp_id = nil if person.usp_id.blank?
  end

  def usp_id_or_invitation
    if usp_id.blank? && !is_template && (invitation_code.blank? || !invitation_task)
      errors.add(:usp_id, _("is being used by another user or is not valid"))
    end
  end

  def invitation_task
    Task.pending.where(code: invitation_code.to_s).first or
      Task.finished.where(code: invitation_code.to_s, target_id: id).first
  end
end
