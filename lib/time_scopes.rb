module TimeScopes
  def self.included(recipient)
    recipient.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended (base)
      if base.respond_to?(:scope) && base.attribute_names.include?('created_at')
        base.class_eval do
          scope :younger_than, lambda { |created_at|
            {:conditions => ["#{table_name}.created_at > ?", created_at]}
          }

          scope :older_than, lambda { |created_at|
            {:conditions => ["#{table_name}.created_at < ?", created_at]}
          }
        end
      end
    end
  end
end
