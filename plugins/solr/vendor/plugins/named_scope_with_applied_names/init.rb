require_dependency 'active_record/named_scope'

if Rails::VERSION::STRING < "2.3.99"

  module ::ActiveRecord

    module NamedScope

      module ClassMethods

        def named_scope_with_applied_names name, options = {}, &block
          named_scope_without_applied_names name, options, &block

          name = name.to_sym
          scopes[name] = lambda do |parent_scope, *args|
            scope = Scope.new(parent_scope, case options
            when Hash
              options
            when Proc
              if self.model_name != parent_scope.model_name
                options.bind(parent_scope).call(*args)
              else
                options.call(*args)
              end
            end, &block)
            scope.scope_name = name
            scope
          end
        end
        alias_method_chain :named_scope, :applied_names
      end

      class Scope
        attr_accessor :scope_name, :scopes_applied

        def initialize_with_applied_names proxy_scope, options, &block
          initialize_without_applied_names proxy_scope, options, &block
          self.scopes_applied ||= []
          self.scopes_applied += proxy_scope.send :scopes_applied if Scope === proxy_scope

          # unrelated bugfix: use if instead of unless
          if (Scope === proxy_scope || ActiveRecord::Associations::AssociationCollection === proxy_scope)
            @current_scoped_methods_when_defined = proxy_scope.send(:current_scoped_methods)
          end
        end
        alias_method_chain :initialize, :applied_names

        def scope_name= name
          @scope_name = name
          self.scopes_applied << @scope_name
        end

      end

    end
  end
end
