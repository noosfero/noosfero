class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

  def error_page
    @message = params[:message]
  end

  protected

  def project_content_has_errors?
    not @content.errors[:base].nil?
  end

end

