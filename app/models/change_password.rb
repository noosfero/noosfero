class ChangePassword < Task

  settings_items :field, :value
  attr_accessor :password, :password_confirmation, :environment_id

  include Noosfero::Plugin::HotSpot

  def self.human_attribute_name(attrib)
    case attrib.to_sym
    when :field
      _('Field')
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

  def plugins_fields
    plugins.dispatch(:change_password_fields).inject({}) { |result, fields| result.merge!(fields)}
  end

  def environment
    (requestor.environment if requestor) || Environment.find_by_id(environment_id)
  end

  def fields
    %w[login email] + plugins_fields.map { |field, name| field.to_s }
  end

  def fields_choice
    [
      [_('Username'), 'login'],
      [_('Email'), 'email'],
    ] + plugins_fields.map { |field, name| [name, field] }
  end

  ###################################################
  # validations for creating a ChangePassword task 
  
  validates_presence_of :field, :value, :environment_id, :on => :create, :message => _('must be filled in')
  # TODO Only on rails3
  # validates_inclusion_of :field, :in => lambda { |data| data.fields }
  validates_each :field do |data, attr, value|
    unless data.fields.include?(value)
      data.errors.add(attr, _('is not in the list of valid fields.'))
    end
  end

  validates_each :value, :on => :create do |data,attr,value|
    unless data.field.blank? || data.value.blank?
      user = data.user_find
      if user.nil? 
        data.errors.add(:value, _('is invalid for the selected field.'))
      end
    end
  end

  before_validation do |change_password|
    user = change_password.user_find
    change_password.requestor = user.person if user
  end

  ###################################################
  # validations for updating a ChangePassword task 

  # only require the new password when actually changing it.
  validates_presence_of :password, :on => :update, :if => lambda { |change| change.status != Task::Status::CANCELLED }
  validates_presence_of :password_confirmation, :on => :update, :if => lambda { |change| change.status != Task::Status::CANCELLED }
  validates_confirmation_of :password, :if => lambda { |change| change.status != Task::Status::CANCELLED }

  def user_find
    begin
      method = "find_by_#{field}_and_environment_id"
      user = nil
      user = User.send(method, value, environment_id) if User.respond_to?(method)
      user = Person.send(method, value, environment_id).user if user.nil? && Person.respond_to?(method)
    rescue
    end
    user
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
