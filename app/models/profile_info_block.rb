class ProfileInfoBlock < Block

  def self.description
    _('Profile information block')
  end

  def content
    user = owner
    lambda do
      render :file => 'account/user_info', :locals => { :user => user }
    end
  end

end
