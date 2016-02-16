
# on STI classes tike Article and Profile, plugins' extensions
# on associations should be reflected on descendants
module ActiveRecord
  module Reflection

    class << self

      def add_reflection_with_descendants(ar, name, reflection)
        self.add_reflection_without_descendants ar, name, reflection
        ar.descendants.each do |k|
          k._reflections.merge!(name.to_s => reflection)
        end if ar.base_class == ar
      end

      alias_method_chain :add_reflection, :descendants

    end
  end
end
