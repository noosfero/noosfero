class EmailActivation < Task

  validates_presence_of :requestor_id, :target_id

  alias :environment :target
  alias :person :requestor

  def validate_on_create
    if !self.requestor.nil? && self.requestor.user.email_activation_pending?
      self.errors.add_to_base(_('You have already requested activation of your mailbox.'))
    end
  end

  def description
    _("'%{user} wants to activate email '%{email}'") % { :user => person.name, :email => person.email_addresses.join(', ') }
  end

  def perform
    person.user.enable_email!
    User::Mailer.deliver_activation_email_notify(person.user)
  end

  def sends_email?
    false
  end

end
