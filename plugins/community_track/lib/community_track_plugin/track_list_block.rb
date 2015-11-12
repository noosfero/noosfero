class CommunityTrackPlugin::TrackListBlock < Block

  include CommunityTrackPlugin::StepHelper

  settings_items :limit, :type => :integer, :default => 3
  settings_items :more_another_page, :type => :boolean, :default => false
  settings_items :category_ids, :type => Array, :default => []

  def self.description
    _('Track List')
  end

  def help
    _('This block displays a list of most relevant tracks.')
  end

  def self.pretty_name
    _('Track List')
  end

  def track_partial
    'track'
  end

  def tracks(page=1, per_page=limit)
    all_tracks.order('hits DESC').paginate(:per_page => per_page, :page => page)
  end

  def count_tracks
    all_tracks.count
  end

  def accept_category?(cat)
    true #accept all?
  end

  def category_ids=(ids)
    settings[:category_ids] = ids.uniq.map{|item| item.to_i unless item.to_i.zero?}.compact
  end

  def categories
    Category.find(category_ids)
  end

  def all_tracks
    tracks = owner.articles.where(:type => 'CommunityTrackPlugin::Track')
    if !category_ids.empty?
      tracks = tracks.joins(:article_categorizations).where(:articles_categories => {:category_id => category_ids})
    end
    tracks
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/track_list', :locals => {:block => block}
    end
  end

  def has_page?(page, per_page=limit)
    return (page-1) * per_page < count_tracks
  end

  def footer
    block = self
    return nil if !has_page?(2)
    proc do
      render :partial => 'blocks/track_list_more', :locals => {:block => block, :page => 2, :per_page => block.limit}
    end
  end

  def self.expire_on
    { :profile => [:article, :category], :environment => [:article, :category] }
  end

end
