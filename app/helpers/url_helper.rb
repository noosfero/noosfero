module UrlHelper

  def back_url
    'javascript:history.back()'
  end

  def default_url_options
    options = {}

    options[:override_user] = params[:override_user] if params[:override_user].present?

    options
  end

end
