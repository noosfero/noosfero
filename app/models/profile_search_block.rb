class ProfileSearchBlock < Block

  def self.description
    _('Display a form to search the profile')
  end

  def content
    title = self.title
    lambda do
      render :file => 'blocks/profile_search', :locals => { :title => title }
    end
  end

  def editable?
    true
  end

end
