class ProfileFieldsBlock < Block

  settings_items :profile_description, :type => :string, :default => ""
  settings_items :show_name, :type => :boolean, :default => false
  attr_accessor :show_name


  def self.description
    _('Profile Fields ')
  end

  def profile_description
    self.settings[:profile_description]
  end

  def help
    _('This block display the description of the community')
  end

  def content(args={})
    self.profile_description = retrive_description_profile_field
    block_content = self.profile_description
    block = self
    s = show_name
    lambda do |object|
      render(
        :file => 'blocks/profile_fields',
        :locals => { :block => block, :show_name => s ,
                     :description => block_content}
      )
    end
  end

  def cacheable?
    false
  end


  private

  def retrive_description_profile_field
    box_id = self.box_id
    owner_id = Box.find(box_id).owner_id
    description = Profile.find(owner_id).description
    if description.blank?
      "Description field are empty or
          not enabled in enviroment"
    else
      description
      end
  end

end
