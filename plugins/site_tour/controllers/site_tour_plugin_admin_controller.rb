require 'csv'

class SiteTourPluginAdminController < PluginAdminController

  no_design_blocks

  def index
    settings = params[:settings]
    settings ||= {}

    @settings = Noosfero::Plugin::Settings.new(environment, SiteTourPlugin, settings)
    @settings.actions_csv = convert_to_csv(@settings.actions)
    @settings.group_triggers_csv = convert_to_csv(@settings.group_triggers)

    if request.post?
      @settings.actions = convert_actions_from_csv(settings[:actions_csv])
      @settings.settings.delete(:actions_csv)

      @settings.group_triggers = convert_group_triggers_from_csv(settings[:group_triggers_csv])
      @settings.settings.delete(:group_triggers_csv)

      @settings.save!
      session[:notice] = 'Settings succefully saved.'
      redirect_to :action => 'index'
    end
  end

  protected

  def convert_to_csv(actions)
    CSV.generate do |csv|
      (actions||[]).each { |action| csv << action.values }
    end
  end

  def convert_actions_from_csv(actions_csv)
    return [] if actions_csv.blank?
    CSV.parse(actions_csv).map do |action|
      {:language => action[0], :group_name => action[1], :selector => action[2], :description => action[3]}
    end
  end

  def convert_group_triggers_from_csv(group_triggers_csv)
    return [] if group_triggers_csv.blank?
    CSV.parse(group_triggers_csv).map do |group|
      {:group_name => group[0], :selector => group[1], :event => group[2]}
    end
  end

end
