class SensitiveContent

  # self.abstract_class = true

  def initialize(args = {})
    @current_user = args[:user]
    @current_page = args[:page]
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

  def directory_to_publish
    if @current_page.folder?
        @current_page
    else
        if @current_page.parent.present?
            @current_page.parent
        else
            nil
        end
    end
  end

  def self.set_context user, page
    context = define_context page
    context.new(user: user, page: page)
  end

  private

  def define_context page
    if page.folder?
      "#{page.class}Context".constantize
    else
        if page.parent.present?
            "#{page.class}Context".constantize
        else
            SensitiveContext
        end
    end
  end

  def publish_permission?
    current_profile.present? &&
    current_user.has_permission?('post_content', current_profile) &&
    (current_profile.organization? || current_profile == current_user)
  end

end
