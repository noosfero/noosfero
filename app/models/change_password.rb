# TODO: send an e-mail with a hash code to the task after the ChangePassword is creatd -> override messages from #Task

class ChangePassword < Task

  serialize :data, Hash
  def data
    self[:data] ||= {}
  end

  attr_accessor :login, :email, :password, :password_confirmation

  ###################################################
  # validations for creating a ChangePassword task 
  
  validates_presence_of :login, :email, :on => :create

  validates_format_of :email, :on => :create, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |obj| !obj.email.blank? })

  validates_each :login, :on => :create do |data,attr,value|
    unless data.login.blank?
      user = User.find_by_login(data.login)
      if user.nil? 
        data.errors.add(:login, _('%{fn} is not a valid username.'))
      else
        if user.email != data.email
          data.errors.add(:email, _('%{fn} is invalid.'))
        end
      end
    end
  end

  before_create do |change_password|
    change_password.requestor = Person.find_by_identifier(change_password.login)
  end

  ###################################################
  # validations for updating a ChangePassword task 

  # only require the new password when actually changing it.
  validates_presence_of :password, :on => :update

  def initialize(*args)
    super(*args)
    self[:data] = {}
  end

  def perform
    user = User.find_by_login(self.login)
    user.force_change_password!(self.password, self.password_confirmation)
  end

  # overriding messages
  
  def cancel_message
    _('Your password change request was cancelled at %s.') % Time.now.to_s
  end

  def finish_message
    _('Your password was changed successfully.')
  end

  def create_message
    hostname = self.requestor.environment.default_hostname
    hash = self.id

    lambda do
      _("In order to change your password, please visit the following address:\n\n%s") % url_for(:host => hostname, :controller => 'account', :action => 'change_password', :hash => hash)
    end
  end

  def description
    _('Password change request')
  end

end
