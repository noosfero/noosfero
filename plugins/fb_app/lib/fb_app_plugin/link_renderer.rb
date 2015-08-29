# add target attribute to links
class FbAppPlugin::LinkRenderer < WillPaginate::ActionView::LinkRenderer

  def prepare collection, options, template
    super
  end

  protected

  def default_url_params
    {target: ''}
  end

end
