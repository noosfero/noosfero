class SensitiveContent
  def initialize(args = {})
    current_user = args[:user]
    current_page = args[:page]
    profile = args[:profile]
    alternative_context = args[:alternative_context]
    select_subdirectory = args[:select_subdirectory]
    @context = GenericContext.set_context(current_user, current_page,
                                          profile, select_subdirectory, alternative_context)
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

  def content_types
    @context.content_types
  end

  def directory_options
    @context.directory_options
  end

  def alternative_context
    @context.alternative_context
  end
end
