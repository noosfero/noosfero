require_dependency 'article'

class Article
  def solr_plugin_comments_updated
    solr_save
  end

  acts_as_faceted :fields => {
      :solr_plugin_f_type => {:label => _('Type'), :proc => proc{|klass| solr_plugin_f_type_proc(klass)}},
      :solr_plugin_f_published_at => {:type => :date, :label => _('Published date'), :queries => {'[* TO NOW-1YEARS/DAY]' => _("Older than one year"),
        '[NOW-1YEARS TO NOW/DAY]' => _("In the last year"), '[NOW-1MONTHS TO NOW/DAY]' => _("In the last month"), '[NOW-7DAYS TO NOW/DAY]' => _("In the last week"), '[NOW-1DAYS TO NOW/DAY]' => _("In the last day")},
        :queries_order => ['[NOW-1DAYS TO NOW/DAY]', '[NOW-7DAYS TO NOW/DAY]', '[NOW-1MONTHS TO NOW/DAY]', '[NOW-1YEARS TO NOW/DAY]', '[* TO NOW-1YEARS/DAY]']},
      :solr_plugin_f_profile_type => {:label => _('Profile'), :proc => proc{|klass| solr_plugin_f_profile_type_proc(klass)}},
      :solr_plugin_f_category => {:label => _('Categories')},
    }, :category_query => proc { |c| "solr_plugin_category_filter:\"#{c.id}\"" },
    :order => [:solr_plugin_f_type, :solr_plugin_f_published_at, :solr_plugin_f_profile_type, :solr_plugin_f_category]

  acts_as_searchable :fields => facets_fields_for_solr + [
      # searched fields
      {:name => {:type => :text, :boost => 2.0}},
      {:slug => :text}, {:body => :text},
      {:abstract => :text}, {:filename => :text},
      # filtered fields
      {:solr_plugin_public => :boolean}, {:environment_id => :integer},
      {:profile_id => :integer}, :language,
      {:solr_plugin_category_filter => :integer},
      # ordered/query-boosted fields
      {:name_sortable => :string}, :last_changed_by_id, :published_at, :is_image,
      :updated_at, :created_at,
    ], :include => [
      {:profile => {:fields => [:name, :identifier, :address, :nickname, :region_id, :lat, :lng]}},
      {:comments => {:fields => [:title, :body, :author_name, :author_email]}},
      {:categories => {:fields => [:name, :path, :slug, :lat, :lng, :acronym, :abbreviation]}},
    ], :facets => facets_option_for_solr,
    :boost => proc { |a| 10 if a.profile && a.profile.enabled },
    :if => proc{ |a| ! ['RssFeed'].include?(a.class.name) }

  private

  def self.solr_plugin_f_type_proc(klass)
    klass.constantize.type_name
  end

  def self.solr_plugin_f_profile_type_proc(klass)
    klass.constantize.type_name
  end

  def solr_plugin_f_type
    #join common types
    case self.class.name
    when 'TinyMceArticle', 'TextileArticle'
      TextArticle.name
    else
      self.class.name
    end
  end

  def solr_plugin_f_profile_type
    self.profile.class.name
  end

  def solr_plugin_f_published_at
    self.published_at
  end

  def solr_plugin_f_category
    self.categories.collect(&:name)
  end

  def solr_plugin_public
    self.public?
  end

  def solr_plugin_category_filter
    categories_including_virtual_ids
  end
end
