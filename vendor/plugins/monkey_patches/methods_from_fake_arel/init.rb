# monkey patch to add fake_arel select, or_scope and where methods
# this gem requires activesupport-2.3.14 and activerecord-2.3.14
# 
# https://github.com/gammons/fake_arel

module Rails3Finder
  def self.included(base)
    base.class_eval do

      # the default named scopes
      named_scope :offset, lambda {|offset| {:offset => offset}}
      named_scope :limit, lambda {|limit| {:limit => limit}}
      named_scope :includes, lambda { |*includes| { :include => includes }}
      named_scope :order, lambda {|*order| {:order => order.join(',') }}
      named_scope :joins, lambda {|*join| {:joins => join } if join[0]}
      named_scope :from, lambda {|*from| {:from => from }}
      named_scope :having, lambda {|*having| {:having => having }}
      named_scope :group, lambda {|*group| {:group => group.join(',') }}
      named_scope :readonly, lambda {|readonly| {:readonly => readonly }}
      named_scope :lock, lambda {|lock| {:lock => lock }}

      def self.select(value = Proc.new)
        if block_given?
          all.select {|*block_args| value.call(*block_args) }
        else
          self.scoped(:select => Array.wrap(value).join(','))
        end
      end

      __where_fn = lambda do |*where|
        if where.is_a?(Array) and where.size == 1
          {:conditions => where.first}
        else
          {:conditions => where}
        end
      end

      named_scope :where, __where_fn

      # Use carefully this method! It might get lost with different classes 
      # scopes or different types of joins. 
      def self.or_scope(*scopes)
        where = []
        joins = []
        includes = []

        # for some reason, flatten is actually executing the scope
        scopes = scopes[0] if scopes.size == 1
        scopes.each do |s|
          s = s.proxy_options
          begin
            where << merge_conditions(s[:conditions])
          rescue NoMethodError
            # I am ActiveRecord::Base. Only my subclasses define merge_conditions:
            where << subclasses.first.merge_conditions(s[:conditions])
          end
          #where << merge_conditions(s[:conditions])
          joins << s[:joins] unless s[:joins].nil?
          includes << s[:include] unless s[:include].nil?
        end
        scoped = self
        scoped = scoped.select("DISTINCT #{self.table_name}.*")
        scoped = scoped.includes(includes.uniq.flatten) unless includes.blank?
        scoped = scoped.joins(joins.uniq.flatten) unless joins.blank?
        scoped.where(where.join(" OR "))
      end
    end
  end
end

ActiveRecord::Base.send :include, Rails3Finder
