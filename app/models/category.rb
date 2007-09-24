class Category < ActiveRecord::Base

  validates_presence_of :name, :environment_id
  belongs_to :environment

  acts_as_tree :order => 'name'

  def full_name(sep = '/')
    self.parent ? (self.parent.full_name(sep) + sep + self.name) : (self.name)
  end
  def level
    self.parent ? (self.parent.level + 1) : 0
  end
  def top_level?
    self.parent.nil?
  end
  def leaf?
    self.children.empty?
  end

  def self.top_level_for(environment)
    self.find(:all, :conditions => ['parent_id is null and environment_id = ?', environment.id ])
  end

  def name=(value)
    self[:name] = value
    unless self.name.blank?
      self.slug = self.name.transliterate.downcase.gsub( /[^-a-z0-9~\s\.:;+=_]/, '').gsub(/[\s\.:;=_+]+/, '-').gsub(/[\-]{2,}/, '-').to_s
    end
  end

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

  before_create do |cat|
    if cat.path == cat.slug && (! cat.top_level?)
      cat.path = cat.calculate_path
    end
  end

end
