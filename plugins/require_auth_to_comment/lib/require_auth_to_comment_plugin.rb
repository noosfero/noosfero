class RequireAuthToCommentPlugin < Noosfero::Plugin

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include FormsHelper

  def self.plugin_name
    "RequireAuthToCommentPlugin"
  end

  def self.plugin_description
    _("Requires users to authenticate in order to post comments.")
  end

  def filter_comment(c)
    c.reject! unless logged_in? || allowed_by_profile
  end

  def profile_editor_extras
    expanded_template('profile-editor-extras.html.erb')
  end

  def stylesheet?
    true
  end

  def js_files
    ['hide_comment_form.js', 'jquery.livequery.min.js']
  end

  def body_beginning
    "<meta name='profile.allow_unauthenticated_comments'/>" if allowed_by_profile
  end

  protected

  delegate :logged_in?, :to => :context

  def allowed_by_profile
    context.profile && context.profile.allow_unauthenticated_comments
  end

end
