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

  def api_content
    description = self.owner.description.present? ? self.owner.description : _("Description field is empty or not enabled on enviroment")
    hash = { description: description }
    Grape::Presenters::Presenter.represent(hash).as_json
  end

  def cacheable?
    false
  end

end
