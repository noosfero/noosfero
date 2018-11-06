class SensitiveContent

  def initialize(args = {})
    current_user = args[:user]
    current_page = args[:page]
    profile = args[:profile]
    @context = GenericContext.set_context(current_user, current_page, profile)
  end

  def context
    @context
  end

  def profile
    @context.selected_profile
  end

  def directory
    @context.directory_to_publish
  end

  def content_options
    @context.content_options
  end

  def directory_options
    profile.folders
  end

end
