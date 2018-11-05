class SensitiveContent

  def initialize(args = {})
    current_user = args[:user]
    current_page = args[:page]
    @context = GenericContext.set_context(current_user, current_page)
    @directory = @context.directory_to_publish
  end

  def context
    @context
  end

  def profile
    unless directory.nil?
      directory.profile
    else
      @context.current_user
    end
  end

  def directory
    @directory
  end

  def content_options
    @context.content_options
  end

  def directory_options
    profile.folders
  end

end
