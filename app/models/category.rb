class Category < ActiveRecord::Base

  attr_accessible :name, :parent_id, :display_color, :display_in_menu, :image_builder, :environment, :parent

  SEARCHABLE_FIELDS = {
    :name => {:label => _('Name'), :weight => 10},
    :acronym => {:label => _('Acronym'), :weight => 5},
    :abbreviation => {:label => _('Abbreviation'), :weight => 5},
    :slug => {:label => _('Slug'), :weight => 1},
  }

  validates_exclusion_of :slug, :in => [ 'index' ], :message => N_('{fn} cannot be like that.').fix_i18n
  validates_presence_of :name, :environment_id
  validates_uniqueness_of :slug,:scope => [ :environment_id, :parent_id ], :message => N_('{fn} is already being used by another category.').fix_i18n
  belongs_to :environment

  # Finds all top level categories for a given environment.
  scope :top_level_for, ->(environment) {
    where 'parent_id is null and environment_id = ?', environment.id
  }

  scope :on_level, ->(parent) { where :parent_id => parent }

  acts_as_filesystem

  has_many :article_categorizations
  has_many :articles, :through => :article_categorizations
  has_many :comments, :through => :articles

  has_many :events, :through => :article_categorizations, :class_name => 'Event', :source => :article

  has_many :profile_categorizations
  has_many :profiles, :through => :profile_categorizations, :source => :profile
  has_many :enterprises, :through => :profile_categorizations, :source => :profile, :class_name => 'Enterprise'
  has_many :people, :through => :profile_categorizations, :source => :profile, :class_name => 'Person'
  has_many :communities, :through => :profile_categorizations, :source => :profile, :class_name => 'Community'

  has_many :products, :through => :enterprises

  acts_as_having_image

  before_save :normalize_display_color

  def normalize_display_color
    display_color.gsub!('#', '') if display_color
    display_color = nil if display_color.blank?
  end

  scope :from_types, ->(types) {
    if types.select{ |t| t.blank? }.empty? then
      where(type: types) else
      where("type IN (?) OR type IS NULL", types.reject{ |t| t.blank? }) end
  }

  def recent_people(limit = 10)
    self.people.reorder('created_at DESC, id DESC').paginate(page: 1, per_page: limit)
  end

  def recent_enterprises(limit = 10)
    self.enterprises.reorder('created_at DESC, id DESC').paginate(page: 1, per_page: limit)
  end

  def recent_communities(limit = 10)
    self.communities.reorder('created_at DESC, id DESC').paginate(page: 1, per_page: limit)
  end

  def recent_products(limit = 10)
    self.products.reorder('created_at DESC, id DESC').paginate(page: 1, per_page: limit)
  end

  def recent_articles(limit = 10)
    self.articles.recent(limit)
  end

  def recent_comments(limit = 10)
    self.comments.reorder('created_at DESC, comments.id DESC').paginate(page: 1, per_page: limit)
  end

  def most_commented_articles(limit = 10)
    self.articles.most_commented(limit)
  end

  def upcoming_events(limit = 10)
    self.events.where('start_date >= ?', DateTime.now.beginning_of_day).order('start_date').paginate(page: 1, per_page: limit)
  end

  def display_in_menu?
    display_in_menu
  end

  def children_for_menu
    results = []
    pending = children.where(display_in_menu: true).all
    while pending.present?
      cat = pending.shift
      results << cat
      pending += cat.children.where :display_in_menu => true
    end

    results
  end

  def is_leaf_displayable_in_menu?
    return false if self.display_in_menu == false
    self.children.where(:display_in_menu => true).empty?
  end

  def with_color
    if display_color.blank?
      parent.nil? ? nil : parent.with_color
    else
      self
    end
  end

end
