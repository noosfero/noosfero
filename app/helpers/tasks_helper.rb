module TasksHelper

  def tasks_url options = {}
    url_for(options.merge(filter_params))
  end

  def filter_params
    filter_fields = ['filter_type', 'filter_text', 'filter_responsible', 'filter_tags']
    params.select {|filter| filter if filter_fields.include? filter }
  end

end
