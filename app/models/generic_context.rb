class GenericContext

  def initialize(args = {})
    @current_user = args[:user]
    @current_page = args[:page]
    @selected_profile = set_selected_profile(args[:profile])
  end

  def self.set_context user, page=nil, profile=nil
    context = self.define_context(page)
    context.new(user: user, page: page, profile: profile)
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

  def content_options
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

  def self.publish_permission? profile, user
    profile.present? &&
    user.has_permission?('post_content', profile) &&
    (profile.organization? || profile == user)
  end

  private

  def self.define_context page=nil
    context = GenericContext
    unless page.nil?
      if page.folder? && const_defined?("#{page.class}Context")
        context = "#{page.class}Context".constantize
      elsif page.parent.present? && const_defined?("#{page.parent.class}Context")
        context = "#{page.parent.class}Context".constantize
      end
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
