class ProfileSearchBlock < Block

  def self.description
    _('Display a form to search the profile')
  end

  def content(args={})
    title = self.title
    lambda do |_|
      render :file => 'blocks/profile_search', :locals => { :title => title }
    end
  end

end
