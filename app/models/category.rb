class Category < ActiveRecord::Base

  SEARCHABLE_FIELDS = {
    :name => 10,
    :acronym => 5,
    :abbreviation => 5,
    :slug => 1,
  }

  validates_exclusion_of :slug, :in => [ 'index' ], :message => N_('%{fn} cannot be like that.').fix_i18n
  validates_presence_of :name, :environment_id
  validates_uniqueness_of :slug,:scope => [ :environment_id, :parent_id ], :message => N_('%{fn} is already being used by another category.').fix_i18n
  belongs_to :environment

  validates_inclusion_of :display_color, :in => [ 1, 2, 3, 4, nil ]
  validates_uniqueness_of :display_color, :scope => :environment_id, :if => (lambda { |cat| ! cat.display_color.nil? }), :message => N_('%{fn} was already assigned to another category.').fix_i18n

  # Finds all top level categories for a given environment. 
  named_scope :top_level_for, lambda { |environment|
    {:conditions => ['parent_id is null and environment_id = ?', environment.id ]}
  }

  named_scope :on_level, lambda { |parent| {:conditions => {:parent_id => parent}} }

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

  named_scope :from_types, lambda { |types|
    types.select{ |t| t.blank? }.empty? ?
      { :conditions => { :type => types } } :
      { :conditions => [ "type IN (?) OR type IS NULL", types.reject{ |t| t.blank? } ] }
  }

  def recent_people(limit = 10)
    self.people.paginate(:order => 'created_at DESC, id DESC', :page => 1, :per_page => limit)
  end

  def recent_enterprises(limit = 10)
    self.enterprises.paginate(:order => 'created_at DESC, id DESC', :page => 1, :per_page => limit)
  end

  def recent_communities(limit = 10)
    self.communities.paginate(:order => 'created_at DESC, id DESC', :page => 1, :per_page => limit)
  end

  def recent_products(limit = 10)
    self.products.paginate(:order => 'created_at DESC, id DESC', :page => 1, :per_page => limit)
  end

  def recent_articles(limit = 10)
    self.articles.recent(limit)
  end

  def recent_comments(limit = 10)
    comments.paginate(:all, :order => 'created_at DESC, comments.id DESC', :page => 1, :per_page => limit)
  end

  def most_commented_articles(limit = 10)
    self.articles.most_commented(limit)
  end

  def upcoming_events(limit = 10)
    self.events.paginate(:conditions => [ 'start_date >= ?', Date.today ], :order => 'start_date', :page => 1, :per_page => limit)
  end

  def display_in_menu?
    display_in_menu
  end

  def children_for_menu
    results = []
    pending = children.find(:all, :conditions => { :display_in_menu => true})
    while !pending.empty?
      cat = pending.shift
      results << cat
      pending += cat.children.find(:all, :conditions => { :display_in_menu => true} )
    end

    results
  end

  def is_leaf_displayable_in_menu?
    return false if self.display_in_menu == false
    self.children.find(:all, :conditions => {:display_in_menu => true}).empty?
  end

end
