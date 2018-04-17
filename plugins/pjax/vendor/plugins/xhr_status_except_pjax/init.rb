class ActionDispatch::Request

  def xml_http_request_with_pjax?
    xml_http_request_without_pjax? and @env['HTTP_X_PJAX'].blank?
  end

end

 ActionDispatch::Request.send :alias_method, :xml_http_request_without_pjax?, :xml_http_request
 ActionDispatch::Request.send :alias_method, :xml_http_request, :xml_http_request_with_pjax?

 ActionDispatch::Request.send :alias_method, :xhr?, :xml_http_request?

