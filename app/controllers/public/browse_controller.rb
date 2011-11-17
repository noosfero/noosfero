class BrowseController < PublicController

  no_design_blocks

  FILTERS = %w(
    more_recent
    more_active
    more_popular
    more_comments
    more_views
  )

  def per_page
    27
  end

  def people
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results = @environment.people.visible.send(@filter)

    if !params[:query].blank?
      @results = @results.find_by_contents(params[:query])
    end
    @results = @results.compact.paginate(:per_page => per_page, :page => params[:page])
  end

  def communities
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results = @environment.communities.visible.send(@filter)

    if !params[:query].blank?
      @results = @results.find_by_contents(params[:query])
    end
    @results = @results.compact.paginate(:per_page => per_page, :page => params[:page])
  end

  def contents
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results = @environment.articles.published.text_articles.send(@filter)

    if !params[:query].blank?
      @results = @results.find_by_contents(params[:query])
    end
    @results = @results.compact.paginate(:per_page => per_page, :page => params[:page])
  end

  protected

  def filter
    if FILTERS.include?(params[:filter])
      params[:filter]
    else
      'more_recent'
    end
  end

  def filter_description(str)
    {
      'people_more_recent' => _('More recent people'),
      'people_more_active' => _('More active people'),
      'people_more_popular' => _('More popular people'),
      'communities_more_recent' => _('More recent communities'),  
      'communities_more_active' => _('More active communities'),  
      'communities_more_popular' => _('More popular communities'),
      'contents_more_recent' => _('More recent contents'),
      'contents_more_views' => _('Most viewed contents'),
      'contents_more_comments' => _('Most commented contents'),
    }[str] || str
  end

end
