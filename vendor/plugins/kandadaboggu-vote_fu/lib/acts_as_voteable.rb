# ActsAsVoteable
module Juixe
  module Acts #:nodoc:
    module Voteable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        #
        # Options:
        #  :vote_counter
        #     Model stores the sum of votes in the  vote counter column when the value is true. This requires a column named `vote_total` in the table corresponding to `voteable` model.
        #     You can also specify a custom vote counter column by providing a column name instead of a true/false value to this option (e.g., :vote_counter => :my_custom_counter.)
        #     Note: Specifying a counter will add it to that model‘s list of readonly attributes using attr_readonly.
        #
        def acts_as_voteable options={}
          has_many :votes, :as => :voteable, :dependent => :destroy
          include Juixe::Acts::Voteable::InstanceMethods
          extend  Juixe::Acts::Voteable::SingletonMethods
          if (options[:vote_counter])
            Vote.send(:include,  Juixe::Acts::Voteable::VoteCounterClassMethods) unless Vote.respond_to?(:vote_counters)
            Vote.vote_counters = [self]
            # define vote_counter_column instance method on voteable
            counter_column_name = (options[:vote_counter] == true) ? :vote_total : options[:vote_counter]
            class_eval <<-EOS
              def self.vote_counter_column           # def self.vote_counter_column
                :"#{counter_column_name}"            #   :vote_total
              end                                    # end
              def vote_counter_column
                self.class.vote_counter_column
              end
            EOS

            define_method(:reload_vote_counter) {reload(:select => vote_counter_column.to_s)}
            attr_readonly counter_column_name
          end
        end
      end

      # This module contains class methods Vote class
      module VoteCounterClassMethods
        def self.included(base)
          base.class_inheritable_array(:vote_counters)
          base.after_create { |record| record.update_vote_counters(1) }
          base.before_destroy { |record| record.update_vote_counters(-1) }
        end

        def update_vote_counters direction
          klass, vtbl = self.voteable.class, self.voteable
          klass.update_counters(vtbl.id, vtbl.vote_counter_column.to_sym => (self.vote * direction) ) if self.vote_counters.any?{|c| c == klass}
        end
      end

      # This module contains class methods
      module SingletonMethods

        # Calculate the vote counts for all voteables of my type.
        # Options:
        #  :start_at    - Restrict the votes to those created after a certain time
        #  :end_at      - Restrict the votes to those created before a certain time
        #  :conditions  - A piece of SQL conditions to add to the query
        #  :limit       - The maximum number of voteables to return
        #  :order       - A piece of SQL to order by. Two calculated columns `count`, and `total`
        #                 are available for sorting apart from other columns. Defaults to `total DESC`.
        #                   Eg: :order => 'count desc'
        #                       :order => 'total desc'
        #                       :order => 'post.created_at desc'
        #  :at_least    - Item must have at least X votes count
        #  :at_most     - Item may not have more than X votes count
        #  :at_least_total    - Item must have at least X votes total
        #  :at_most_total     - Item may not have more than X votes total
        def tally(options = {})
          order("total DESC").all options_for_tally(options)
        end

        def options_for_tally (options = {})
            options.assert_valid_keys :start_at, :end_at, :conditions, :at_least, :at_most, :order, :limit, :at_least_total, :at_most_total

            scope = scope(:find)
            start_at = sanitize_sql(["#{Vote.table_name}.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
            end_at = sanitize_sql(["#{Vote.table_name}.created_at <= ?", options.delete(:end_at)]) if options[:end_at]

            if respond_to?(:vote_counter_column)
              # use the counter cache column if present.
              total_col       = "#{table_name}.#{vote_counter_column}"
              at_least_total  = sanitize_sql(["#{total_col} >= ?", options.delete(:at_least_total)]) if options[:at_least_total]
              at_most_total   = sanitize_sql(["#{total_col} <= ?", options.delete(:at_most_total)])  if options[:at_most_total]
            end
            conditions = [
              options[:conditions],
              at_least_total,
              at_most_total,
              start_at,
              end_at
            ]

            conditions = conditions.compact.join(' AND ')
            conditions = merge_conditions(conditions, scope[:conditions]) if scope

            type_and_context = "#{Vote.table_name}.voteable_type = #{quote_value(base_class.name)}"
            joins = ["LEFT OUTER JOIN #{Vote.table_name} ON #{table_name}.#{primary_key} = #{Vote.table_name}.voteable_id AND #{type_and_context}"]
            joins << scope[:joins] if scope && scope[:joins]
            at_least  = sanitize_sql(["COUNT(#{Vote.table_name}.id) >= ?", options.delete(:at_least)]) if options[:at_least]
            at_most   = sanitize_sql(["COUNT(#{Vote.table_name}.id) <= ?", options.delete(:at_most)]) if options[:at_most]
            at_least_total = at_most_total = nil # reset the values
            unless respond_to?(:vote_counter_column)
              # aggregate the votes when counter cache is absent.
              total_col       = "SUM(#{Vote.table_name}.vote)"
              at_least_total  = sanitize_sql(["#{total_col} >= ?", options.delete(:at_least_total)]) if options[:at_least_total]
              at_most_total   = sanitize_sql(["#{total_col} <= ?", options.delete(:at_most_total)]) if options[:at_most_total]
            end
            having    = [at_least, at_most, at_least_total, at_most_total].compact.join(' AND ')
            group_by  = "#{Vote.table_name}.voteable_id HAVING COUNT(#{Vote.table_name}.id) > 0"
            group_by << " AND #{having}" unless having.blank?

            { :select     => "#{table_name}.*, COUNT(#{Vote.table_name}.id) AS count, #{total_col} AS total",
              :joins      => joins.join(" "),
              :conditions => conditions,
              :group      => group_by
            }.update(options)
        end

      end

      # This module contains instance methods
      module InstanceMethods
        def votes_for
          self.votes.where(vote: 1).count
        end

        def votes_against
          self.votes.where(vote: -1).count
        end

        # Same as voteable.votes.size
        def votes_count
          self.votes.size
        end

        def votes_total
          respond_to?(:vote_counter_column) ? send(self.vote_counter_column) : self.votes.sum(:vote)
        end

        def voters_who_voted
          self.votes.collect(&:voter)
        end

        def voted_by?(voter, for_or_against = "all")
          options = (for_or_against == "all") ? {} : {:vote => (for_or_against ? 1 : -1)}
          self.votes.exists?({:voter_id => voter.id, :voter_type => voter.class.base_class.name}.merge(options))
        end
      end
    end
  end
end
