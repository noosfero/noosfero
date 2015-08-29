class OpenGraphPlugin::Settings < Noosfero::Plugin::Settings

  def self.new base, attrs = {}
    super base, self.parents.first, attrs
  end

  OpenGraphPlugin::TrackConfig::Types.each do |track, klass|
    define_method "#{track}_track_enabled=" do |value|
      super ActiveRecord::Type::Boolean.new.send :cast_value, value
    end
  end

end

