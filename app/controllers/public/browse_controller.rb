class BrowseController < PublicController

  no_design_blocks

  FILTERS = %w(
    more_recent
    more_active
    more_popular
  )

  def people
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results = @environment.people.send(@filter)

    if params[:query].blank?
      @results = @results.paginate(:per_page => 27, :page => params[:page])
    else
      @results = @results.find_by_contents(params[:query]).paginate(:per_page => 27, :page => params[:page])
    end
  end

  def communities
    @filter = filter
    @title = self.filter_description(params[:action] + '_' + @filter )

    @results = @environment.communities.send(@filter)

    if params[:query].blank?
      @results = @results.paginate(:per_page => 27, :page => params[:page])
    else
      @results = @results.find_by_contents(params[:query]).paginate(:per_page => 27, :page => params[:page])
    end
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
      'people_more_recent' => _('People more recent'),
      'people_more_active' => _('People more active'),
      'people_more_popular' => _('People more popular'),
      'communities_more_recent' => _('Communities more recent'),
      'communities_more_active' => _('Communities more active'),
      'communities_more_popular' => _('Communities more popular'),
    }[str] || str
  end

end
