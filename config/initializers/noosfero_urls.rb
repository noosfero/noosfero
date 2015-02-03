if Rails.env == 'development'
  ActionController::Base.send(:prepend_before_filter) do |controller|
    # XXX note that this is not thread-safe! Accessing a Noosfero instance in
    # development mode under different ports concurrently _will_ lead to weird
    # things happening.
    if [80,443].include?(controller.request.port)
      url_options = {}
    else
      url_options = { :port => controller.request.port }
    end
    Noosfero.instance_variable_set('@development_url_options', url_options)
  end
end
