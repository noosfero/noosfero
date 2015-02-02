class ActionDispatch::Request

  def xml_http_request_with_pjax?
    xml_http_request_without_pjax? and @env['HTTP_X_PJAX'].blank?
  end

end

 ActionDispatch::Request.send :alias_method_chain, :xml_http_request?, :pjax
 ActionDispatch::Request.send :alias_method, :xhr?, :xml_http_request?

