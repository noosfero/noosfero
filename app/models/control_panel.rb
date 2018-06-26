class ControlPanel
  class << self
    @@path = File.join(Rails.root, 'app', 'models', 'control_panel', '*.rb')

    @@core_entries ||= Dir.glob(@@path).map do |entry_path|
      require entry_path
      "ControlPanel::#{File.basename(entry_path, '.rb').camelize}".constantize
    end.reject {|entry| entry == ControlPanel::Entry}.sort_by {|entry| entry.priority}

    def core_sections
      {
        profile: {name: _('Profile'), priority: 10},
        content: {name: _('Content'), priority: 20},
        design: {name: _('Design'), priority: 30},
        interests: {name: _('Interests'), priority: 40},
        relationships: {name: _('Relationships'), priority: 50},
        security: {name: _('Security'), priority: 60},
        enterprise: {name: _('Enterprise'), priority: 70},
        mail: {name: _('E-mail'), priority: 80},
        others: {name: _('Others'), priority: 100},
      }
    end

    def entries(environment)
      plugins = Noosfero::Plugin::Manager.new(environment, self)
      entries_list = @@core_entries + plugins.dispatch(:control_panel_entries)
      entries_list = entries_list.sort_by {|entry| entry.priority}

      entries_list.inject({}) do |result, entry|
        result[entry.section] = [] if result[entry.section].blank?
        result[entry.section] << entry
        result
      end
    end

    def sections(environment)
      current_sections = core_sections
      plugins = Noosfero::Plugin::Manager.new(environment, self)
      plugins.dispatch(:control_panel_sections).each do |section|
        section.each do |identifier, attributes|
          current_sections[identifier] = attributes
        end
      end
      current_sections
    end

    def ordered_sections(environment)
      sections(environment).sort_by {|identifier, attributes| attributes[:priority]}.map {|section| section[0]}
    end

    def available_entries(section_identifier, user, profile, context={})
      entries(profile.environment)[section_identifier.to_s].try(:select) {|entry| entry.display?(user, profile, context)}
    end
  end
end
