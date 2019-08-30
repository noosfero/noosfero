class LoginBlock < Block
  def self.description
    _("Login/logout")
  end

  def help
    _("This block presents a login/logout block.")
  end

  def cacheable?
    false
  end
end
