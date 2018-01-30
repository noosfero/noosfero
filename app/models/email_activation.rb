class EmailActivation < Task

  validates_presence_of :requestor_id, :target_id

  validates :requestor, kind_of: {kind: Person}
  validates :target, kind_of: {kind: Environment}

  validate :already_requested, :on => :create

  will_notify :activation_email_notify, mailer: UserMailer

  alias :environment :target
  alias :person :requestor

  def already_requested
    if !self.requestor.nil? && self.requestor.person? && self.requestor.user.email_activation_pending?
      self.errors.add(:base, _('You have already requested activation of your mailbox.'))
    end
  end

  def title
    _("Email activation")
  end

  def subject
    person.email_addresses.join(', ')
  end

  def information
    {:message => _("%{requestor} wants to activate the following email: %{subject}.")}
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def perform
    person.user.enable_email!
  end

  # :nodoc:
  def after_finish
    notify(:activation_email_notify, person.user)
  end

  def sends_email?
    false
  end

end
