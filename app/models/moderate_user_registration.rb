class ModerateUserRegistration < Task
  settings_items :user_id, type: String
  settings_items :name, type: String
  settings_items :author_name, type: String
  settings_items :email, type: String

  after_create :schedule_spam_checking

  validates :target, kind_of: { kind: Environment }

  alias :environment :target
  alias :environment= :target=

  def schedule_spam_checking
    self.delay.check_for_spam
  end

  include Noosfero::Plugin::HotSpot

  def sender
    "#{name} (#{email})"
  end

  def custom_fields_moderate
    true
  end

  def perform
    user = environment.users.find_by(id: user_id)
    user.activate!
  end

  def title
    _("New user")
  end

  def subject
    name
  end

  def information
    { message: _("%{sender} wants to register."),
      variables: { sender: sender } }
  end

  def icon
    result = { type: :defined_image, src: "/images/icons-app/person-minor.png", name: name }
  end

  def target_notification_description
    _("%{sender} tried to register.") %
      { sender: sender }
  end

  def target_notification_message
    target_notification_description + "\n\n" +
      _("You need to login on %{system} in order to approve or reject this user.") % { environment: self.environment }
  end

  def target_notification_message
    _("User \"%{user}\" just requested to register. You have to approve or reject it through the \"Pending Validations\" section in your control panel.\n") % { user: self.name } + target_custom_fields
  end

  def target_custom_fields
    header = ""
    reason = ""
    if requestor.present?
      requestor.custom_field_values.includes(:custom_field).each do |custom_value|
        if custom_value.custom_field.moderation_task
          header = _("\nModerated Fields\n")
          reason += "#{custom_value.custom_field.name}: #{custom_value.value}\n"
        end
      end
    end
    header + reason
  end
end
