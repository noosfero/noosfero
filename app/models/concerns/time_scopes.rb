# This module provides the following scopes:
#   * older_than(:created_at)
#   * younger_than(:created_at)
#   * created_at(:start_date, :end_date)
#   * updated_at(:start_date, :end_date)
#   * published_at(:start_date, :end_date)

module TimeScopes
  def self.included(recipient)
    recipient.extend(ClassMethods)
  end

  module ClassMethods
    def self.extended (base)
      if base.respond_to?(:scope)
        if base.attribute_names.include?('created_at')
          base.class_eval do
            scope :younger_than, lambda { |created_at|
              where "#{table_name}.created_at > ?", created_at
            }

            scope :older_than, lambda { |created_at|
              where "#{table_name}.created_at < ?", created_at
            }
          end
        end

        attributes = %w[updated_at created_at published_at]
        attributes.each do |attribute|
          if base.attribute_names.include?(attribute)
            base.class_eval do
              scope attribute, -> start_date, end_date {
                if start_date.present?
                  start_date = DateTime.parse(start_date) unless start_date.kind_of?(DateTime)
                  start_term = "#{table_name}.#{attribute} > ?"
                else
                  start_date = nil
                end

                if end_date.present?
                  end_date = DateTime.parse(end_date) unless end_date.kind_of?(DateTime)
                  end_term = "#{table_name}.#{attribute} < ?"
                else
                  end_date = nil
                end

                where [start_term, end_term].compact.join(' AND '), *[start_date, end_date].compact
              }
            end
          end
        end
      end
    end
  end
end
