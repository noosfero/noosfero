require 'action_view/helpers/jquery_helper'
require 'action_view/helpers/jquery_ui_helper'
require 'action_view/template/handlers/rjs'
require 'jrails/javascript_helper'
require 'jrails/rendering'

ActionView::Base.class_eval do
  cattr_accessor :debug_rjs
  self.debug_rjs = false
end

ActionView::Base.class_eval do
  #require 'jrails/asset_tag_ext'
  include ActionView::Helpers::JqueryHelper
  include ActionView::Helpers::JqueryUiHelper
  include ActionView::Helpers::JavaScriptHelper
end

ActionView::TestCase.class_eval do
  #require 'jrails/asset_tag_ext'
  include ActionView::Helpers::JqueryHelper
  include ActionView::Helpers::JqueryUiHelper
  include ActionView::Helpers::JavaScriptHelper
end

ActionView::Template.register_template_handler :rjs, ActionView::Template::Handlers::RJS.new
