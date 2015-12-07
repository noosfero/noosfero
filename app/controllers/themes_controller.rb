class ThemesController < ApplicationController

  before_filter :login_required
  before_filter :check_user_can_edit_appearance, :only => [:index]

  no_design_blocks

  # attr_reader :target

  def target
    @target
  end

  def index
    @environment = environment
    @themes = (environment.themes + Theme.approved_themes(target)).uniq.sort_by { |t| t.name }

    @current_theme = target.theme

    @layout_templates = LayoutTemplate.all
    @current_template = target.layout_template
  end

  def set
    target.update_theme(params[:id])
    redirect_to :action => 'index'
  end

  def unset
    if target.kind_of?(Environment)
      target.update_theme('default')
    else
      target.update_theme(nil)
    end
    redirect_to :action => 'index'
  end

  def set_layout_template
    target.update_layout_template(params[:id])
    redirect_to :action => 'index'
  end

  private

  def check_user_can_edit_appearance
    user_can_edit_appearance = user.is_admin?(environment) || environment.enabled?('enable_appearance')
    redirect_to request.referer || "/" unless user_can_edit_appearance
  end

end
