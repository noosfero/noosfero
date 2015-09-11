class ChangePassword < Task

  attr_accessor :password, :password_confirmation

  def self.human_attribute_name_with_customization(attrib, options={})
    case attrib.to_sym
    when :password
      _('Password')
    when :password_confirmation
      _('Password Confirmation')
    else
      _(self.human_attribute_name_without_customization(attrib))
    end
  end
  class << self
    alias_method_chain :human_attribute_name, :customization
  end

  validates_presence_of :requestor

  validates :requestor, kind_of: {kind: Person}

  ###################################################
  # validations for updating a ChangePassword task 

  # only require the new password when actually changing it.
  validates_presence_of :password, :on => :update, :if => lambda { |change| change.status != Task::Status::CANCELLED }
  validates_presence_of :password_confirmation, :on => :update, :if => lambda { |change| change.status != Task::Status::CANCELLED }
  validates_confirmation_of :password, :if => lambda { |change| change.status != Task::Status::CANCELLED }

  def environment
    requestor.environment unless requestor.nil?
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

  include Rails.application.routes.url_helpers
  def task_created_message
    hostname = self.requestor.environment.default_hostname
    code = self.code
    url = url_for(:host => hostname, :controller => 'account', :action => 'new_password', :code => code)

    proc do
      _("In order to change your password, please visit the following address:\n\n%s\n\nIf you did not required any change to your password just desconsider this email.") % url
    end
  end

end
