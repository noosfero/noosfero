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

  # Finds all top level categories for a given environment. 
  def self.top_level_for(environment)
    self.find(:all, :conditions => ['parent_id is null and environment_id = ?', environment.id ])
  end

  acts_as_filesystem

  has_many :article_categorizations
  has_many :articles, :through => :article_categorizations
  has_many :comments, :through => :articles

  has_many :events, :through => :article_categorizations, :class_name => 'Event', :source => :article

  has_many :profile_categorizations
  has_many :enterprises, :through => :profile_categorizations, :source => :profile, :class_name => 'Enterprise'
  has_many :people, :through => :profile_categorizations, :source => :profile, :class_name => 'Person'
  has_many :communities, :through => :profile_categorizations, :source => :profile, :class_name => 'Community'

  has_many :products, :through => :enterprises

  acts_as_having_image

  def recent_articles(limit = 10)
    self.articles.recent(limit)
  end

  def recent_comments(limit = 10)
    comments.find(:all, :order => 'created_at DESC, comments.id DESC', :limit => limit)
  end

  def most_commented_articles(limit = 10)
    self.articles.most_commented(limit)
  end

  def total_items
    # FIXME this can be SLOW (??)
    articles.count + comments.count + enterprises.count + people.count + communities.count + products.count
  end

  def display_in_menu?
    if ENV['RAILS_ENV'] == 'development'
      return true
    end

    # FIXME don't hardcode like this. Should be a setting of the environment, maybe
    total_items >= 10
  end

end
