class LoginBlock < Block

  def self.description
    _('Login/logout')
  end

  def help
    _('This block presents a login/logout block.')
  end

  def content
    lambda do
      render :file => 'blocks/login_block'
    end
  end

  def cacheable?
    false
  end

end
