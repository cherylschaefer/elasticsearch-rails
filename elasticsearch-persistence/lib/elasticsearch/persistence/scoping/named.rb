module Elasticsearch
  module Persistence
    module Scoping
      module Named
        extend ActiveSupport::Concern

        module ClassMethods
          def all(options={})
            if current_scope
              current_scope.clone
            else
              default_scoped
            end
          end

          def default_scoped # :nodoc:
            relation.merge(build_default_scope)
          end

          # Collects attributes from scopes that should be applied when creating
          # an AR instance for the particular class this is called on.
          def scope_attributes # :nodoc:
            all.scope_for_create
          end

          # Are there default attributes associated with this scope?
          def scope_attributes? # :nodoc:
            current_scope || default_scopes.any?
          end

          def scope(name, body, &block)
            if dangerous_class_method?(name)
              raise ArgumentError, "You tried to define a scope named \"#{name}\" " \
                "on the model \"#{self.name}\", but Active Record already defined " \
                "a class method with the same name."
            end

            extension = Module.new(&block) if block

            singleton_class.send(:define_method, name) do |*args|
              scope = all.scoping { body.call(*args) }
              scope = scope.extending(extension) if extension

              scope || all
            end
          end
        end
      end
    end
  end
end