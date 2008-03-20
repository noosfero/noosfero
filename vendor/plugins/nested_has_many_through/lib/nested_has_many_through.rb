# Copyright (c) 2007 Matt Westcott
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module ActiveRecord #:nodoc:

  module Reflection # :nodoc:
    class AssociationReflection < MacroReflection #:nodoc:
      def check_validity!
        if options[:through]
          if through_reflection.nil?
            raise HasManyThroughAssociationNotFoundError.new(active_record.name, self)
          end
          
          if source_reflection.nil?
            raise HasManyThroughSourceAssociationNotFoundError.new(self)
          end

          if options[:source_type] && source_reflection.options[:polymorphic].nil?
            raise HasManyThroughAssociationPointlessSourceTypeError.new(active_record.name, self, source_reflection)
          end
          
          if source_reflection.options[:polymorphic] && options[:source_type].nil?
            raise HasManyThroughAssociationPolymorphicError.new(active_record.name, self, source_reflection)
          end
          
          # override check_validity! here to always permit has_many associations
          # (including has_many :through) to be used as through/source associations
          unless [:belongs_to, :has_many].include?(source_reflection.macro)
            raise HasManyThroughSourceAssociationMacroError.new(self)
          end
        end
      end
    end
  end

  module Associations #:nodoc:
    class HasManyThroughAssociation < AssociationProxy #:nodoc:
    
      def initialize(owner, reflection)
        super
        reflection.check_validity!
      end

      def find(*args)
        options = args.extract_options!  #Base.send(:extract_options_from_args!, args)

        conditions = construct_conditions
        if sanitized_conditions = sanitize_sql(options[:conditions])
          conditions = conditions.dup << " AND (#{sanitized_conditions})"
        end
        options[:conditions] = conditions

        if options[:order] && @reflection.options[:order]
          options[:order] = "#{options[:order]}, #{@reflection.options[:order]}"
        elsif @reflection.options[:order]
          options[:order] = @reflection.options[:order]
        end

        options[:select]  = construct_select(options[:select])
        options[:from]  ||= construct_from
        options[:joins]   = construct_joins + " #{options[:joins]}"
        options[:include] = @reflection.source_reflection.options[:include] if options[:include].nil?

        merge_options_from_reflection!(options)

        # Pass through args exactly as we received them.
        args << options
        @reflection.klass.find(*args)
      end

      protected

        # Build SQL conditions from attributes, qualified by table name.
        def construct_conditions
          if @constructed_conditions.nil?
            @join_components ||= construct_join_components
            @constructed_conditions = "#{@join_components[:remote_key]} = #{@owner.quoted_id} #{@join_components[:conditions]}"
          end
          @constructed_conditions
        end

        def construct_joins
          @join_components ||= construct_join_components
          @join_components[:joins]
        end

        # Given any belongs_to or has_many (including has_many :through) association,
        # return the essential components of a join corresponding to that association, namely:
        # joins: any additional joins required to get from the association's table (reflection.table_name)
        #    to the table that's actually joining to the active record's table
        # remote_key: the name of the key in the join table (qualified by table name) which will join
        #    to a field of the active record's table
        # local_key: the name of the key in the local table (not qualified by table name) which will
        #    take part in the join
        # conditions: any additional conditions (e.g. filtering by type for a polymorphic association,
        #    or a :conditions clause explicitly given in the association), including a leading AND
        def construct_join_components(reflection = @reflection, association_class = reflection.klass, table_ids = {association_class.table_name => 1})
        
          if reflection.macro == :has_many and reflection.through_reflection
            # Construct the join components of the source association, so that we have a path from
            # the eventual target table of the association up to the table named in :through, and
            # all tables involved are allocated table IDs.
            source_join_components = construct_join_components(reflection.source_reflection, reflection.klass, table_ids)
            # Determine the alias of the :through table; this will be the last table assigned
            # when constructing the source join components above.
            through_table_alias = through_table_name = reflection.through_reflection.table_name
            through_table_alias += "_#{table_ids[through_table_name]}" unless table_ids[through_table_name] == 1

            # Construct the join components of the through association, so that we have a path to
            # the active record's table.
            through_join_components = construct_join_components(reflection.through_reflection, reflection.through_reflection.klass, table_ids)

            # Any subsequent joins / filters on owner attributes will act on the through association,
            # so that's what we return for the conditions/keys of the overall association.
            conditions = through_join_components[:conditions]
            conditions += " AND #{interpolate_sql(reflection.klass.send(:sanitize_sql, reflection.options[:conditions]))}" if reflection.options[:conditions]
            {
              :joins => "#{source_join_components[:joins]} INNER JOIN #{table_name_with_alias(through_table_name, through_table_alias)} ON (#{source_join_components[:remote_key]} = #{through_table_alias}.#{source_join_components[:local_key]}#{source_join_components[:conditions]}) #{through_join_components[:joins]} #{reflection.options[:joins]}",
              :remote_key => through_join_components[:remote_key],
              :local_key => through_join_components[:local_key],
              :conditions => conditions
            }
          else
            # reflection is not has_many :through; it's a standard has_many / belongs_to instead
            
            # Determine the alias used for remote_table_name, if any. In all cases this will already
            # have been assigned an ID in table_ids (either through being involved in a previous join,
            # or - if it's the first table in the query - as the default value of table_ids)
            remote_table_alias = remote_table_name = association_class.table_name
            remote_table_alias += "_#{table_ids[remote_table_name]}" unless table_ids[remote_table_name] == 1

            # Assign a new alias for the local table.
            local_table_alias = local_table_name = reflection.active_record.table_name
            if table_ids[local_table_name]
              table_id = table_ids[local_table_name] += 1
              local_table_alias += "_#{table_id}"
            else
              table_ids[local_table_name] = 1
            end
            
            conditions = ''
            # Add filter for single-table inheritance, if applicable.
            conditions += " AND #{remote_table_alias}.#{association_class.inheritance_column} = #{association_class.quote_value(association_class.name.demodulize)}" unless association_class.descends_from_active_record?
            # Add custom conditions
            conditions += " AND (#{interpolate_sql(association_class.send(:sanitize_sql, reflection.options[:conditions]))})" if reflection.options[:conditions]
            
            if reflection.macro == :belongs_to
              if reflection.options[:polymorphic]
                conditions += " AND #{local_table_alias}.#{reflection.options[:foreign_type]} = #{reflection.active_record.quote_value(association_class.base_class.name.to_s)}"
              end
              {
                :joins => reflection.options[:joins],
                :remote_key => "#{remote_table_alias}.#{association_class.primary_key}",
                :local_key => reflection.primary_key_name,
                :conditions => conditions
              }
            else
              # Association is has_many (without :through)
              if reflection.options[:as]
                conditions += " AND #{remote_table_alias}.#{reflection.options[:as]}_type = #{reflection.active_record.quote_value(reflection.active_record.base_class.name.to_s)}"
              end
              {
                :joins => "#{reflection.options[:joins]}",
                :remote_key => "#{remote_table_alias}.#{reflection.primary_key_name}",
                :local_key => reflection.klass.primary_key,
                :conditions => conditions
              }
            end
          end
        end

        def table_name_with_alias(table_name, table_alias)
          table_name == table_alias ? table_name : "#{table_name} #{table_alias}"
        end

    end
  end
end
