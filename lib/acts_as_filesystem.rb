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
      acts_as_tree :order => 'name', :counter_cache => :children_count

      # calculate the right path
      before_create do |record|
        if record.path == record.slug && (! record.top_level?)
          record.path = record.calculate_path
        end
        true
      end

      # when renaming a category, all children categories must have their paths
      # recalculated
      after_update do |record|
        if record.recalculate_path
          record.children.each do |item|
            item.path = item.calculate_path
            item.recalculate_path = true
            item.save!
          end
        end
        record.recalculate_path = false
        true
      end

    end
  end

  module InstanceMethods
    # used to know when to trigger batch renaming
    attr_accessor :recalculate_path

    # calculates the full name of a category by accessing the name of all its
    # ancestors.
    #
    # If you have this category hierarchy:
    #   Category "A"
    #     Category "B"
    #       Category "C"
    #
    # Then Category "C" will have "A/B/C" as its full name.
    def full_name(sep = '/')
      self.hierarchy.map {|item| item.name || '?' }.join(sep)
    end

    # gets the name without leading parents. Usefull when dividing categories
    # in top-level groups and full names must not include the top-level
    # category which is already a emphasized label
    def full_name_without_leading(count, sep = '/')
      parts = self.full_name(sep).split(sep)
      count.times { parts.shift }
      parts.join(sep)
    end

    # calculates the level of the category in the category hierarchy. Top-level
    # categories have level 0; the children of the top-level categories have
    # level 1; the children of categories with level 1 have level 2, and so on.
    #
    #      A    level 0
    #     / \
    #    B   C  level 1
    #   / \ / \
    #   E F G H level 2
    #     ...
    def level
      self.parent ? (self.parent.level + 1) : 0
    end

    # Is this category a top-level category?
    def top_level?
      self.parent.nil?
    end

    # Is this category a leaf in the hierarchy tree of categories?
    #
    # Being a leaf means that this category has no subcategories.
    def leaf?
      self.children.empty?
    end

    def set_name(value)
      if self.name != value
        self.recalculate_path = true
      end
      self[:name] = value
    end

    # sets the name of the category. Also sets #slug accordingly.
    def name=(value)
      self.set_name(value)
      unless self.name.blank?
        self.slug = self.name.to_slug
      end
    end

    # sets the slug of the category. Also sets the path with the new slug value.
    def slug=(value)
      self[:slug] = value
      unless self.slug.blank?
        self.path = self.calculate_path
      end
    end

    # calculates the full path to this category using parent's path.
    def calculate_path
      if self.top_level?
        self.slug
      else
        self.parent.calculate_path + "/" + self.slug
      end
    end

    def top_ancestor
      self.top_level? ? self : self.parent.top_ancestor
    end

    def explode_path
      path.split(/\//)
    end

    # returns the full hierarchy from the top-level item to this one. For
    # example, if item1 has a children item2 and item2 has a children item3,
    # then item3's hierarchy would be [item1, item2, item3].
    #
    # If +reload+ is passed as +true+, then the hierarchy is reload (usefull
    # when the ActiveRecord object was modified in some way, or just after
    # changing parent)
    def hierarchy(reload = false)
      if reload
        @hierarchy = nil
      end

      unless @hierarchy
        @hierarchy = []
        item = self
        while item
          @hierarchy.unshift(item)
          item = item.parent
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

  end
end

ActiveRecord::Base.extend ActsAsFileSystem::ClassMethods

