class PeopleBlockBase < ProfileListBlock
  settings_items :prioritize_profiles_with_image, :type => :boolean, :default => true
  settings_items :limit, :type => :integer, :default => 6
  settings_items :name, :type => String, :default => ""
  settings_items :address, :type => String, :default => ""
  attr_accessible :name, :address, :prioritize_profiles_with_image

  def self.description
    _('Random people')
  end

  def help
    c_('Clicking on the people or groups will take you to their home page.')
  end

  def default_title
    _('{#} People')
  end

  def base_profiles
    owner.people
  end

  def extra_option
    { }
  end

  def api_content(params = {})
    people = profiles(params[:current_person])
    content = {}
    content['people'] = Api::Entities::Person.represent(people.limit(self.limit).sort{|x,y| x.name <=> y.name}).as_json
    content['#'] = people.count
    content
  end

end
