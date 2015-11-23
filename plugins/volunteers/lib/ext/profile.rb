require_dependency 'profile'

# attr_accessible must be defined on subclasses
Profile.descendants.each do |subclass|
  subclass.class_eval do
    attr_accessible :volunteers_settings
  end
end

class Profile

  def volunteers_settings attrs = {}
    @volunteers_settings ||= Noosfero::Plugin::Settings.new self, VolunteersPlugin, attrs
    attrs.each{ |a, v| @volunteers_settings.send "#{a}=", v }
    @volunteers_settings
  end
  alias_method :volunteers_settings=, :volunteers_settings

end
