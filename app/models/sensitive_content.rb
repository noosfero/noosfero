class SensitiveContent

  # self.abstract_class = true

  def initialize(args = {})
    current_user = args[:user]
    current_page = args[:page]
    @context = GenericContext.set_context(current_user, current_page)
  end

  def context
    @context
  end

  def current_user
   @context.current_user
  end

  def directory
    @context.directory_to_publish
  end

  def content_options
    @context.content_options
  end

end
