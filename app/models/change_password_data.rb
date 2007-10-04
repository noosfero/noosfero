class ChangePasswordData < Validator

  attr_accessor :login, :email

  validates_presence_of :login, :email
  validates_format_of :email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda { |obj| !obj.email.blank? })

  # 
  validates_each :login do |data,attr,value|
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

  def initialize(hash = nil)
    hash ||= {}
    self.login = hash[:login] || hash['login']
    self.email = hash[:email] || hash['email']
  end

  def confirm!
    raise ActiveRecord::RecordInvalid unless self.valid?
    user = User.find_by_login(self.login)
    #ChangePassword.create!(:user_id => user.id)
  end

end
