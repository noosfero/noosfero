# FIXME: this tests must me moved into design plugin

require File.dirname(__FILE__) + '/../test_helper'
require 'edit_template_controller'

# Re-raise errors caught by the controller.
class EditTemplateController; def rescue_action(e) raise e end; end

class EditTemplateControllerTest < Test::Unit::TestCase

  def setup
    @controller = EditTemplateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @rejected_dirs = ['.', '..', '.svn']
    @theme_dir_path = "#{RAILS_ROOT}/public/themes"
    @icons_dir_path = "#{RAILS_ROOT}/public/icons"
  end

  def test_select_theme_html
    get :index
    available_themes = Dir.new(@theme_dir_path).to_a - @rejected_dirs
    available_themes.collect do |t|
      assert_tag :tag => 'select', :attributes => {:id => 'theme_name', :name => 'theme_name'}, :child => {:tag =>"option", :attributes => {:value => t}}
    end
  end


  def test_select_icons_theme_html
    get :index
    available_icons = Dir.new(@icons_dir_path).to_a - @rejected_dirs
    available_icons.collect do |t|
      assert_tag :tag => 'select', :attributes => {:id => 'icons_theme_name', :name => 'icons_theme_name'}, :child => {:tag =>"option", :attributes => {:value => t}}
    end
  end

end
