class ProfileInfoBlock < Block

  def self.description
    _('Profile information block')
  end

  def content
    block = self
    lambda do
      render :file => 'blocks/profile_info', :locals => { :block => block }
    end
  end

end
