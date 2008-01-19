class LoginBlock < Block

  def self.description
    _('A login box for your users.')
  end

  def content
    { :controller => 'account', :action => 'login_block' }
  end

end
