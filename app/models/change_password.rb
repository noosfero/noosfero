class ChangePassword < Task

  settings_items :value
  attr_accessor :password, :password_confirmation, :environment_id

  include Noosfero::Plugin::HotSpot

  def self.human_attribute_name(attrib)
    case attrib.to_sym
    when :value
      _('Value')
    when :password
      _('Password')
    when :password_confirmation
      _('Password Confirmation')
    else
      _(self.superclass.human_attribute_name(attrib))
    end
  end

  def environment
    (requestor.environment if requestor) || Environment.find_by_id(environment_id)
  end

  def plugins_options
    plugins.dispatch(:change_password_fields)
  end

  def user_fields
    %w[login email] + plugins_options.select {|options| options[:model].to_sym == :user }.map { |options| options[:field].to_s }
  end

  def person_fields
    %w[] + plugins_options.select {|options| options[:model].to_sym == :person }.map { |options| options[:field].to_s }
  end

  def fields
    user_fields + person_fields
  end

  def fields_label
    labels = [
      _('Username'),
      _('Email'),
    ] + plugins_options.map { |options| options[:name] }

    last = labels.pop
    label = labels.join(', ')
    "#{label} #{_('or')} #{last}"
  end

  ###################################################
  # validations for creating a ChangePassword task 
  
  validates_presence_of :value, :environment_id, :on => :create, :message => _('must be filled in')

  validates_each :value, :on => :create do |data,attr,value|
    unless data.value.blank?
      users = data.find_users
      if users.blank?
        data.errors.add(:value, _('"%s" is not valid.') % value.to_s)
      end
    end
  end

  before_validation do |change_password|
    users = change_password.find_users
    change_password.requestor ||= users.first.person if users.present?
  end

  ###################################################
  # validations for updating a ChangePassword task 

  # only require the new password when actually changing it.
  validates_presence_of :password, :on => :update, :if => lambda { |change| change.status != Task::Status::CANCELLED }
  validates_presence_of :password_confirmation, :on => :update, :if => lambda { |change| change.status != Task::Status::CANCELLED }
  validates_confirmation_of :password, :if => lambda { |change| change.status != Task::Status::CANCELLED }

  def build_query(fields)
    fields.map {|field| "#{field} = '#{value}'"}.join(' OR ')
  end

  def find_users
    results = []
    person_query = build_query(person_fields)
    user_query = build_query(user_fields)

    results += Person.where(person_query).where(:environment_id => environment.id).map(&:user)
    results += User.where(user_query).where(:environment_id => environment.id)
    results
  end

  def title
    _("Change password")
  end

  def information
    {:message => _('%{requestor} wants to change its password.')}
  end

  def icon
    {:type => :profile_image, :profile => requestor, :url => requestor.url}
  end

  def perform
    user = self.requestor.user
    user.force_change_password!(self.password, self.password_confirmation)
  end

  def target_notification_description
    _('%{requestor} wants to change its password.') % {:requestor => requestor.name}
  end

  # overriding messages
  
  def task_cancelled_message
    _('Your password change request was cancelled at %s.') % Time.now.to_s
  end

  def task_finished_message
    _('Your password was changed successfully.')
  end

  include ActionController::UrlWriter
  def task_created_message
    hostname = self.requestor.environment.default_hostname
    code = self.code
    url = url_for(:host => hostname, :controller => 'account', :action => 'new_password', :code => code)

    lambda do
      _("In order to change your password, please visit the following address:\n\n%s") % url 
    end
  end

end
