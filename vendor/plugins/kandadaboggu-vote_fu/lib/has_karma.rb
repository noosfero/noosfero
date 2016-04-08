# Has Karma

module PeteOnRails
  module VoteFu #:nodoc:
    module Karma #:nodoc:

      def self.included(base)
        base.extend ClassMethods
        class << base
          attr_accessor :karmatic_objects
        end
      end

      module ClassMethods
        def has_karma(voteable_type)
          self.class_eval <<-RUBY
            def karma_voteable
              #{voteable_type.to_s.classify}
            end
          RUBY
          include PeteOnRails::VoteFu::Karma::InstanceMethods
          extend  PeteOnRails::VoteFu::Karma::SingletonMethods
          if self.karmatic_objects.nil?
            self.karmatic_objects = [eval(voteable_type.to_s.classify)]
          else
            self.karmatic_objects.push(eval(voteable_type.to_s.classify))
          end
        end
      end

      # This module contains class methods
      module SingletonMethods

        ## Not yet implemented. Don't use it!
        # Find the most popular users
        def find_most_karmic
          all
        end

      end

      # This module contains instance methods
      module InstanceMethods
        def karma(options = {})
          karma_value = 0
          self.class.karmatic_objects.each do |object|
            karma_value += object
              .where("u.id = ? AND vote = ?" , self[:id] , true)
              .joins("inner join votes v on #{object.table_name}.id = v.voteable_id")
              .joins("inner join #{self.class.table_name} u on u.id = #{object.name.tableize}.#{self.class.name.foreign_key}")
              .length
          end
          return karma_value
        end

      end

    end
  end
end
