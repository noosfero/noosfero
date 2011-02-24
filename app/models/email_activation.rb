class EmailActivation < Task

  validates_presence_of :requestor_id, :target_id

  alias :environment :target
  alias :person :requestor

  def validate_on_create
    if !self.requestor.nil? && self.requestor.user.email_activation_pending?
      self.errors.add_to_base(_('You have already requested activation of your mailbox.'))
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

  def target_notification_description
    _("%{requestor} wants to activate the following email: %{subject}.") % {:requestor => requestor.name, :subject => subject }
  end

  def perform
    person.user.enable_email!
  end

  # :nodoc:
  def after_finish
    User::Mailer.deliver_activation_email_notify(person.user)
  end

  def sends_email?
    false
  end

end
