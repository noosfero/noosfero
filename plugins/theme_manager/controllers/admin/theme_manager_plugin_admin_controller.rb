_dir = File.dirname(__FILE__)
require File.join _dir, '../../helpers/theme_manager_helper'
require 'fileutils'

class ThemeManagerPluginAdminController < AdminController

  include ThemeManagerHelper
  
  before_filter :create_temp, only: :add_theme
  after_filter :destroy_temp, only: :add_theme

  def index
    @enabled_themes = list_enabled_themes
    @disabled_themes = list_disabled_themes
    @error = session[error_key]
    session[error_key] = nil
  end

  def add_theme
    if request.post?
      temp_pack = get_theme_package @temp, params['theme-package']
      unless temp_pack[:file_type] == 'application/zip'
        return session[error_key] = "The file type #{temp_pack[:file_type]} is not valid. Theme packages must be Zip files."
      end
      theme_dir_temp = File.join @temp, 'theme-dir'
      success, stderr = unzip_file(temp_pack[:zip], theme_dir_temp)
      unless success
        return session[error_key] = _('Failure to unzip. Error: %s') % stderr
      end
      theme_dir_temp = find_theme_root theme_dir_temp
      theme_info = validate_theme_files theme_dir_temp
      unless theme_info[:name]
        return session[error_key] = _('Bad theme content. Error: %s') % theme_info[:error]
      end
      sucess, err = activate_theme theme_dir_temp, theme_info[:name], environment
      unless sucess
        session[error_key] = _('Cant install this theme. Error: %s') % err
      end
    end
    session[:notice] = _('Theme %s added') % theme_info[:name]
    redirect_to controller: 'theme_manager_plugin_admin'
  end

  def disable
    theme_dir = File.join Rails.root, '/public/designs/themes/'
    disabled_dir = File.join theme_dir, 'disabled_themes'
    unless Dir.exists? disabled_dir
      begin
      Dir.mkdir disabled_dir
      rescue Exception => err
        session[error_key] = (err.message + '<br>' +
          _('Ask sysadmin to give write permission to the %{user} user at %{dir}.') % {user: ENV['USER'], dir: theme_dir}).html_safe
        redirect_to colntroller: 'theme_manager_plugin_admin'
        return
      end
    end
    begin
    FileUtils.move File.join(theme_dir, params[:id]), disabled_dir
    session[:notice] = _("The theme %s has been disabled") % params[:id]
    rescue  Exception => err
      session[:notice] = _("Fail to disable the %s theme") % params[:id]
      session[error_key] = _("The theme %{id} has not been disabled. Error: %{err}") % {id: params[:id], err: err.message}
    end
    redirect_to controller: 'theme_manager_plugin_admin', action: 'index'
  end

  def enable
    begin
      theme_dir = File.join Rails.root , '/public/designs/themes/'
      enabled_dir = File.join theme_dir, 'disabled_themes', params[:id]
      FileUtils.move  enabled_dir, theme_dir
      @message = _("The theme %s has been enabled") % params[:id]
      session[:notice] = @message
    rescue Exception =>err
      @message = _("The theme %{id} has not been enabled error %{err}") % {id: params[:id], err: err.message}
      session[error_key] = @message
    end
    redirect_to controller: 'theme_manager_plugin_admin', action: 'index'
  end
  
  def hide
    begin
      environment.settings[:themes].delete params[:id]
      environment.save!
      @message = _("The theme %s has been installed") % params[:id]
      session[:notice] = @message
    rescue Exception => err
      @message = _("The theme %{id} has not been uninstalled erro %{err}") % {id: params[:id], err: err.message}
      session[error_key] = @message
    end
    redirect_to controller: 'theme_manager_plugin_admin', action: 'index'
  end

  def show
    begin
      environment.add_themes [params[:id]]
      environment.save!
      @message = _("The theme %s has been enabled") % params[:id]
      session[:notice] = @message
    rescue Exception => err
      @message = _("The theme %{id} has not been enabled erro %{err}") % {id:params[:id], err:err.message}
      session[error_key] = @message
    end
    redirect_to controller: 'theme_manager_plugin_admin', action:'index'
  end

  protected

  def create_temp
    @temp = Dir.mktmpdir 'noosfero-theme-manager-plugin'
  end

  def destroy_temp
    FileUtils.rm_rf @temp
  end

  def error_key
    self.class.name + '_error'
  end

end
