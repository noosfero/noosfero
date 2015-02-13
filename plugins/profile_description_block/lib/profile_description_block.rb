class ProfileDescriptionBlock < Block
  settings_items :show_name, :type => :boolean,
                 :default => false

  attr_accessor :show_name

  def self.description
    _('Profile Description')
  end

  def help
    _('this block displays the description field of the profile')
  end

  def default_title
    _('PROFILE DESCRIPTION')
  end

  def content(args={})
    description =  if self.owner.description.blank?
                      "Description field is empty or
                        not enabled on enviroment"
                   else
                      self.owner.description
                   end
    block = self
    s = show_name
    proc do
      render(
        :file => 'blocks/profile_description',
        :locals => { :block => block, :show_name => s ,
                     :description => description}
      )
    end
  end

  def cacheable?
    false
  end

end
