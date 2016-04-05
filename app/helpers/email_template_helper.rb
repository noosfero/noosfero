module EmailTemplateHelper

  def mail_with_template(params={})
    if params[:email_template].present?
      params[:body] = params[:email_template].parsed_body(params[:template_params])
      params[:subject] = params[:email_template].parsed_subject(params[:template_params])
      params[:content_type] = "text/html"
    end
    mail(params.except(:email_template))
  end

end
