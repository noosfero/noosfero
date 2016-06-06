# on STI classes tike Article and Profile, plugins' extensions
# on associations should be reflected on descendants
module ActiveRecord
  module Reflection
    def self.add_reflection(ar, name, reflection)
      (ar.descendants << ar).each do |klass|
        klass.clear_reflections_cache
        klass._reflections = klass._reflections.merge(name.to_s => reflection)
      end
    end
  end
end
