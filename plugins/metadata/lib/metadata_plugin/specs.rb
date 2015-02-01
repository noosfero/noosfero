module MetadataPlugin::Specs

  module ClassMethods

    def self.extended base
      base.class_attribute :metadata_specs
      base.metadata_specs ||= {}
    end

    def metadata_spec spec = {}
      namespace = spec[:namespace]
      # setters are used to avoid propagation to super classes, see http://apidock.com/rails/Class/class_attribute
      if _spec = self.metadata_specs[namespace]
        self.metadata_specs = self.metadata_specs.deep_merge(namespace => _spec.deep_merge(spec))
      else
        self.metadata_specs = self.metadata_specs.deep_merge(namespace => spec)
      end
    end

  end

end
