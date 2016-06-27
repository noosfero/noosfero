class PersonTagsPlugin < Noosfero::Plugin

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include FormsHelper

  def self.plugin_name
    "PersonTagsPlugin"
  end

  def self.plugin_description
    _("People can define tags that describe their interests.")
  end

  def profile_editor_extras
    expanded_template('profile-editor-extras.html.erb').html_safe
  end

  def self.api_mount_points
    [PersonTagsPlugin::API]
  end

  def self.extra_blocks
    {
      PersonTagsPlugin::InterestsBlock => { type: Person }
    }
  end

  def self.has_admin_url?
    false
  end

  def stylesheet?
    true
  end
end
