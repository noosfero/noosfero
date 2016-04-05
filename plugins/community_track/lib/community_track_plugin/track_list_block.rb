class CommunityTrackPlugin::TrackListBlock < Block

  include CommunityTrackPlugin::StepHelper

  settings_items :limit, :type => :integer, :default => 3
  settings_items :more_another_page, :type => :boolean, :default => false
  settings_items :category_ids, :type => Array, :default => []
  settings_items :order, :type => :string, :default => 'hits'

  attr_accessible :more_another_page, :category_ids, :order

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
    tracks = all_tracks
    tracks = case order
             when 'newer'
               tracks.order('created_at DESC')
             when 'random'
               tracks.order('random()')
             else
               tracks.order('hits DESC')
             end
    tracks.paginate(:per_page => per_page, :page => page)
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

  def has_page?(page, per_page=limit)
    return (page-1) * per_page < count_tracks
  end

  def self.expire_on
    { :profile => [:article, :category], :environment => [:article, :category] }
  end

  def timeout
    1.hour
  end

  def set_seed(new_seed=false)
    block = self
    proc do
      if block.order == 'random'
        if new_seed || cookies[:_noosfero_community_tracks_rand_seed].blank?
          cookies[:_noosfero_community_tracks_rand_seed] = {value: rand, expires: Time.now + 600}
        end
        #XXX postgresql specific
        seed_val = Environment.connection.quote(cookies[:_noosfero_community_tracks_rand_seed])
        Environment.connection.execute("select setseed(#{seed_val})")
      end
    end
  end

  def self.order_options
    {_('Hits') => 'hits', _('Random') => 'random', _('Most Recent') => 'newer'}
  end

end
