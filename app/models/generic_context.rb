class GenericContext

  def initialize(args = {})
    @current_user = args[:user]
    @current_page = args[:page]
  end

  def self.set_context user, page=nil
    context = self.define_context(page)
    context.new(user: user, page: page)
  end

  def current_user
    @current_user
  end

  def current_page
    @current_page
  end

  def current_profile
    @current_page.profile unless @current_page.nil?
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
      if GenericContext.publish_permission? current_profile, current_user
        if current_page.folder?
            directory = current_page
        elsif current_page.parent.present?
            directory = current_page.parent
        end
      else
        directory = sensitive_directory_in_user_profile
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

  def sensitive_directory_in_user_profile
    nil
  end

end
