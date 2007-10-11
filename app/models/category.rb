class Category < ActiveRecord::Base

  validates_exclusion_of :slug, :in => [ 'index' ], :message => N_('%{fn} cannot be like that.')
  validates_presence_of :name, :environment_id
  validates_uniqueness_of :slug,:scope => [ :environment_id, :parent_id ], :message => N_('%{fn} is already being used by another category.')
  belongs_to :environment

  validates_inclusion_of :display_color, :in => [ 1, 2, 3, 4, nil ]
  validates_uniqueness_of :display_color, :scope => :environment_id, :if => (lambda { |cat| ! cat.display_color.nil? }), :message => N_('%{fn} was already assigned to another category.')

  def validate
    if self.parent && (self.class != self.parent.class)
      self.errors.add(:type, _("%{fn} must be the same as the parents'"))
    end
  end

  acts_as_tree :order => 'name'

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
    my_name = self.name ? self.name : '?'
    self.parent ? (self.parent.full_name(sep) + sep + my_name) : (my_name)
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

  # Finds all top level categories for a given environment. 
  def self.top_level_for(environment)
    self.find(:all, :conditions => ['parent_id is null and environment_id = ?', environment.id ])
  end

  # used to know when to trigger batch renaming
  attr_accessor :recalculate_path

  # sets the name of the category. Also sets #slug accordingly.
  def name=(value)
    if self.name != value
      self.recalculate_path = true
    end

    self[:name] = value
    unless self.name.blank?
      self.slug = self.name.transliterate.downcase.gsub( /[^-a-z0-9~\s\.:;+=_]/, '').gsub(/[\s\.:;=_+]+/, '-').gsub(/[\-]{2,}/, '-').to_s
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

  # calculate the right path
  before_create do |cat|
    if cat.path == cat.slug && (! cat.top_level?)
      cat.path = cat.calculate_path
    end
  end

  # when renaming a category, all children categories must have their paths
  # recalculated
  after_update do |cat|
    if cat.recalculate_path
      cat.children.each do |item|
        item.path = item.calculate_path
        item.recalculate_path = true
        item.save!
      end
    end
    cat.recalculate_path = false
  end

  def top_ancestor
    self.top_level? ? self : self.parent.top_ancestor
  end

  def explode_path
    path.split(/\//)
  end

end
