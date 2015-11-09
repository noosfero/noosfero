module ActsAsFileSystem

  module ActsMethods

    # Declares the ActiveRecord model to acts like a filesystem: objects are
    # arranged in a tree (liks acts_as_tree), and . The underlying table must
    # have the following fields:
    #
    # * name (+:string+) - the title of the object
    # * slug (+:string+)- the title turned in a URL-friendly string (downcased,
    #   non-ascii chars transliterated into ascii, all sequences of
    #   non-alphanumericd characters changed into dashed)
    # * path (+:text+)- stores the full path of the object (the full path of
    #   the parent, a "/" and the slug of the object)
    # * children_count - a cache of the number of children elements.
    def acts_as_filesystem
      # a filesystem is a tree
      acts_as_tree :counter_cache => :children_count

      extend ClassMethods
      include InstanceMethods
      if self.has_path?
        after_update :update_children_path
        before_create :set_path
        include InstanceMethods::PathMethods
      end

      before_save :set_ancestry
    end

  end

  module ClassMethods

    def build_ancestry(parent_id = nil, ancestry = '')
      ActiveRecord::Base.transaction do
        self.base_class.where(parent_id: parent_id).each do |node|
          node.update_column :ancestry, ancestry

          build_ancestry node.id, (ancestry.empty? ? "#{node.formatted_ancestry_id}" :
                                   "#{ancestry}#{node.ancestry_sep}#{node.formatted_ancestry_id}")
        end
      end

      #raise "Couldn't reach and set ancestry on every record" if self.base_class.where('ancestry is null').count != 0
    end

    def has_path?
      (['name', 'slug', 'path'] - self.column_names).blank?
    end

  end

  module InstanceMethods

    def ancestry_column
      'ancestry'
    end
    def ancestry_sep
      '.'
    end
    def has_ancestry?
      self.class.column_names.include? self.ancestry_column
    end

    def formatted_ancestry_id
      "%010d" % self.id if self.id
    end

    def ancestry
      self[ancestry_column]
    end
    def ancestor_ids
      return nil if !has_ancestry? or ancestry.nil?
      @ancestor_ids ||= ancestry.split(ancestry_sep).map{ |id| id.to_i }
    end

    def ancestry=(value)
      self[ancestry_column] = value
    end
    def set_ancestry
      return unless self.has_ancestry?
      if self.ancestry.nil? or (new_record? or parent_id_changed?) or recalculate_path
        self.ancestry = self.hierarchy(true)[0...-1].map{ |p| p.formatted_ancestry_id }.join(ancestry_sep)
      end
    end

    def descendents_options
      ["#{self.ancestry_column} LIKE ?", "%#{self.formatted_ancestry_id}%"]
    end
    def descendents
      self.class.where descendents_options
    end

    # calculates the level of the record in the records hierarchy. Top-level
    # records have level 0; the children of the top-level records have
    # level 1; the children of records with level 1 have level 2, and so on.
    #
    #      A    level 0
    #     / \
    #    B   C  level 1
    #   / \ / \
    #   E F G H level 2
    #     ...
    def level
      self.hierarchy.size - 1
    end

    # Is this record a top-level record?
    def top_level?
      self.parent.nil?
    end

    # Is this record a leaf in the hierarchy tree of records?
    #
    # Being a leaf means that this record has no subrecord.
    def leaf?
      self.children.empty?
    end

    def top_ancestor
      if has_ancestry? and !ancestry.nil?
        self.class.base_class.find_by_id self.top_ancestor_id
      else
        self.hierarchy.first
      end
    end
    def top_ancestor_id
      if has_ancestry? and !ancestry.nil?
        self.ancestor_ids.first
      else
        self.hierarchy.first.id
      end
    end

    # returns the full hierarchy from the top-level item to this one. For
    # example, if item1 has a children item2 and item2 has a children item3,
    # then item3's hierarchy would be [item1, item2, item3].
    #
    # If +reload+ is passed as +true+, then the hierarchy is reload (usefull
    # when the ActiveRecord object was modified in some way, or just after
    # changing parent)
    def hierarchy(reload = false)
      @hierarchy = nil if reload or recalculate_path

      if @hierarchy.nil?
        @hierarchy = []

        if !reload and !recalculate_path and ancestor_ids
          objects = self.class.base_class.where(id: ancestor_ids)
          ancestor_ids.each{ |id| @hierarchy << objects.find{ |t| t.id == id } }
          @hierarchy << self
        else
          item = self
          while item
            @hierarchy.unshift(item)
            item = item.parent
          end
        end
      end

      @hierarchy
    end

    def map_traversal(&block)
      result = []
      current_level = [self]

      while !current_level.empty?
        result += current_level
        ids = current_level.select {|item| item.children_count > 0}.map(&:id)
        break if ids.empty?
        current_level = self.class.base_class.where(parent_id: ids)
      end
      block ||= (lambda { |x| x })
      result.map(&block)
    end

    def all_children
      res = map_traversal
      res.shift
      res
    end

    #####
    # Path methods
    # These methods are used when _path_, _name_ and _slug_ attributes exist
    # and should be calculated based on the tree
    #####
    module PathMethods
      # used to know when to trigger batch renaming
      attr_accessor :recalculate_path

      # calculates the full path to this record using parent's path.
      def calculate_path
        self.hierarchy.map{ |obj| obj.slug }.join('/')
      end
      def set_path
        if self.path == self.slug && !self.top_level?
          self.path = self.calculate_path
        end
      end
      def explode_path
        path.split(/\//)
      end

      def update_children_path
        if self.recalculate_path
          self.children.each do |child|
            child.path = child.calculate_path
            child.recalculate_path = true
            child.save!
          end
        end
        self.recalculate_path = false
      end

      # calculates the full name of a record by accessing the name of all its
      # ancestors.
      #
      # If you have this record hierarchy:
      #   Record "A"
      #     Record "B"
      #       Record "C"
      #
      # Then Record "C" will have "A/B/C" as its full name.
      def full_name(sep = '/')
        self.hierarchy.map {|item| item.name || '?' }.join(sep)
      end

      # gets the name without leading parents. Useful when dividing records
      # in top-level groups and full names must not include the top-level
      # record which is already a emphasized label
      def full_name_without_leading(count, sep = '/')
        parts = self.full_name(sep).split(sep)
        count.times { parts.shift }
        parts.join(sep)
      end

      def set_name(value)
        if self.name != value
          self.recalculate_path = true
        end
        self[:name] = value
      end

      # sets the name of the record. Also sets #slug accordingly.
      def name=(value)
        self.set_name(value)
        unless self.name.blank?
          self.slug = self.name.to_slug
        end
      end

      # sets the slug of the record. Also sets the path with the new slug value.
      def slug=(value)
        self[:slug] = value
        unless self.slug.blank?
          self.path = self.calculate_path
        end
      end
    end
  end
end

ActiveRecord::Base.extend ActsAsFileSystem::ActsMethods

