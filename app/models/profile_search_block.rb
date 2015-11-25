class ProfileSearchBlock < Block

  def self.description
    _('Display a form to search the profile')
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/profile_search', :locals => { :block => block }
    end
  end

end
