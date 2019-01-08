module JRails
  JQUERY_VAR = 'jQuery'
end

require 'action_view/helpers/jquery_helper'
require 'action_view/helpers/jquery_ui_helper'
require 'jrails/javascript_helper'

ActionView::Base.class_eval do
  include ActionView::Helpers::JqueryHelper
  include ActionView::Helpers::JqueryUiHelper
  include ActionView::Helpers::JavaScriptHelper
end
