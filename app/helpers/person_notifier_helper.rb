module PersonNotifierHelper

  include ApplicationHelper

  private

  def path_to_image(source)
    top_url + source
  end

  def top_url
    top_url = @profile.environment ? @profile.environment.top_url : ''
  end

end
