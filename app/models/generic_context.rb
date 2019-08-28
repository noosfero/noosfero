class GenericContext

  def initialize(args = {})
    @current_user = args[:user]
    @current_page = args[:page]
    @selected_profile = set_selected_profile(args[:profile])
    @select_subdirectory = args[:select_subdirectory]
    @alternative_context = args[:alternative_context]
  end

  def self.set_context user, page=nil, profile=nil, select_subdirectory=false,
    alternative_context=nil

    context = self.define_context(page, alternative_context)
    context.new(user: user, page: page, profile: profile,
                select_subdirectory: select_subdirectory,
                alternative_context: alternative_context)
  end

  def current_user
    @current_user
  end

  def current_page
    @current_page
  end

  def selected_profile
    @selected_profile
  end

  def select_subdirectory
    @select_subdirectory
  end

  def alternative_context
    @alternative_context
  end

  def content_types
    [
        TextArticle,
        Event,
        Folder,
        Blog,
        UploadedFile,
        Forum,
        Gallery,
        RssFeed
    ]
  end

  def directory_to_publish
    directory = nil
    unless current_page.nil?
      if current_page.profile == selected_profile
        directory = get_page_directory
      else
        directory = sensitive_directory_in_profile
      end
    end
    directory
  end

  def directory_options
    if select_subdirectory
      Folder.subdirectories selected_profile, directory_to_publish
    else
      Folder.subdirectories selected_profile
    end
  end

  def self.publish_permission? profile, user
    profile.present? &&
    user.has_permission?('post_content', profile) &&
    (profile.organization? || profile == user)
  end

  private

  def self.define_context page=nil, alternative_context=nil
    context = GenericContext
    if !page.nil? && const_defined?("#{page.class}Context")
      context = "#{page.class}Context".constantize
    elsif !page.nil? && !page.parent.nil? && const_defined?("#{page.parent.class}Context")
      context = "#{page.parent.class}Context".constantize
    elsif !alternative_context.nil? && const_defined?("#{alternative_context}Context")
      context = "#{alternative_context}Context".constantize
    end
    context
  end

  def set_selected_profile profile
    if !profile.nil? && GenericContext.publish_permission?(profile, current_user)
      profile
    else
      current_user
    end
  end

  def get_page_directory
    unless current_page.nil?
      if current_page.folder?
        current_page
      else
        current_page.parent
      end
    end
  end

  def sensitive_directory_in_profile
    nil
  end

end
