require 'action_controller/routing'

class ActionController::Routing::RouteSet
  alias :orig_extract_request_environment :extract_request_environment
  def extract_request_environment(request)
    orig_extract_request_environment(request).merge(:host => request.host)
  end
end

class ActionController::Routing::Route
  alias :orig_recognition_conditions :recognition_conditions
  def recognition_conditions
    result = orig_recognition_conditions
    result << "conditions[:if].call(env)" if conditions[:if]
    result
  end
end

