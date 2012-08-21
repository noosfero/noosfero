module ActsAsFileSystem

  module ClassMethods

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
      include ActsAsFileSystem::InstanceMethods

      # a filesystem is a tree
      acts_as_tree :counter_cache => :children_count

      before_create :set_path
      before_save :set_ancestry
      after_update :update_children_path
    end

  end

  module InstanceMethods

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

    def has_ancestry?
      self.class.column_names.include? 'ancestry'
    end
    def ancestry
      self['ancestry']
    end
    def ancestry=(value)
      self['ancestry'] = value
    end
    # get the serialized tree from database column 'ancetry'
    # and convert it to an array
    def ancestry_ids
      return nil if !has_ancestry? or ancestry.nil?
      @ancestry_ids ||= ancestry.split('.').map{ |id| id.to_i }
    end
    def set_ancestry
      return unless self.has_ancestry?
      if self.ancestry.nil? or (new_record? or parent_id_changed?) or recalculate_path
        self.ancestry = self.hierarchy[0...-1].map{ |p| "%010d" % p.id }.join('.')
      end
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
      self.hierarchy.first
    end
    def top_ancestor_id
      self.ancestry_ids.first
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

        if ancestry_ids
          objects = self.class.base_class.all(:conditions => {:id => ancestry_ids})
          ancestry_ids.each{ |id| @hierarchy << objects.find{ |t| t.id == id } }
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
        current_level = self.class.base_class.find(:all, :conditions => { :parent_id => ids})
      end
      block ||= (lambda { |x| x })
      result.map(&block)
    end

    def all_children
      res = map_traversal
      res.shift
      res
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

ActiveRecord::Base.extend ActsAsFileSystem::ClassMethods

