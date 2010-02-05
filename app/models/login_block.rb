class LoginBlock < Block

  def self.description
    _('Login/logout')
  end

  def help
    _('This block presents a login/logout block.')
  end

  def content
    lambda do
      if logged_in?
        render :file => 'account/user_info'
      else
        render :file => 'account/login_block'
      end
    end
  end

  def cacheable?
    false
  end

end
