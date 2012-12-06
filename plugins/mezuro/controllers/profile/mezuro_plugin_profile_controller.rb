#TODO Ver quais metodos precisam estar aqui e fazer os testes
class MezuroPluginProfileController < ProfileController

  append_view_path File.join(File.dirname(__FILE__) + '/../../views')

=begin
  rescue_from Exception do |exception|
    @message = process_error_message exception.message
    render :partial => "error_page"
  end

  def error_page
    @message = params[:message]
  end
=end
  protected

  def process_error_message message
    if message =~ /undefined method `module' for nil:NilClass/
      "Kalibro did not return any result. Verify if the selected configuration is correct."
    else
      message
    end
  end

  def project_content_has_errors?
    not @content.errors[:base].nil?
  end
  
  def redirect_to_error_page(message)
    message = URI.escape(CGI.escape(process_error_message(message)),'.')
    redirect_to "/profile/#{profile.identifier}/plugin/mezuro/error_page?message=#{message}"
  end

end

