class CreateUser < Task

  settings_items :email, :type => String
  settings_items :name, :type => String
  settings_items :author_name, :type => String
  settings_items :person_data, :type => String

  after_create :schedule_spam_checking

  alias :environment :target
  alias :environment= :target=

  DATA_FIELDS = Person.fields + ['name', 'email', 'login', 'author_name', 'password', 'password_confirmation']
  DATA_FIELDS.each do |field|
    settings_items field.to_sym
  end

  def schedule_spam_checking
    self.delay.check_for_spam
  end

  include Noosfero::Plugin::HotSpot

  def sender
    "#{name} (#{email})"
  end

  def perform
    user = User.new(user_data)
    user.person = Person.new(person_data)
    user.person.identifier = user.login
    author_name = user.name
    user.environment = self.environment
    user.person.environment = user.environment
    user.signup!
  end

  def title
    _("New user")
  end

  def subject
    name
  end

  def information
    { :message => _('%{sender} wants to register.'),
      :variables => {:sender => sender} }
  end

  def icon
    result = {:type => :defined_image, :src => '/images/icons-app/person-minor.png', :name => name}
  end

  def target_notification_description
    _('%{sender} tried to register.') %
    {:sender => sender}
  end

  def target_notification_message
    target_notification_description + "\n\n" +
    _('You need to login on %{system} in order to approve or reject this user.') % {  :environment => self.environment }
  end

  def target_notification_message
    _("User \"%{user}\" just requested to register. You have to approve or reject it through the \"Pending Validations\" section in your control panel.\n") % { :user => self.name }
  end

  protected
 
  def user_data
     user_data = self.data.reject do |key, value|
      !DATA_FIELDS.include?(key.to_s)
    end
 
    user_data
  end
end