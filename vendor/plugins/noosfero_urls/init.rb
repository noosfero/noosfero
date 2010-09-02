if Rails.env == 'development'
  ActionController::Base.send(:prepend_before_filter) do |controller|
    Noosfero.instance_variable_set('@development_url_options', { :port => controller.request.port })
  end
end
