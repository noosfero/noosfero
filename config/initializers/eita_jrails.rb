module JRails
  JQUERY_VAR = 'jQuery'
end

require 'action_view/helpers/jquery_helper'
require 'action_view/helpers/jquery_ui_helper'
require 'jrails/javascript_helper'

ActiveSupport::Reloader.to_prepare do
  ActionView::Base.class_eval do
    include ActionView::Helpers::JqueryHelper
    include ActionView::Helpers::JqueryUiHelper
    include ActionView::Helpers::JavaScriptHelper

    cattr_accessor :debug_rjs
    self.debug_rjs = false
  end
end
