module FbAppPlugin::DisplayHelper

  extend CatalogHelper

  def fb_url_options options
    options.merge! page_id: @page_ids, signed_request: @signed_requests, id: nil
  end

  def url_for options = {}
    return super unless options.is_a? Hash
    if options[:controller] == :catalog
      options[:controller] = :fb_app_plugin_page_tab
      options = fb_url_options options
    end
    super
  end

  protected

  def product_url_options product, options = {}
    options = options.merge! product.url
    options = options.merge! controller: :fb_app_plugin_page_tab, product_id: product.id, action: :index
    options = fb_url_options options
    unless Rails.env.development?
      domain = FbAppPlugin.config[:app][:domain]
      options[:host] = domain if domain.present?
      options[:protocol] = '//'
    end
    options
  end
  def product_path product, options = {}
    url = url_for product_url_options(product, options = {})
    url
  end

  def link_to_product product, opts = {}
    url_opts = opts.delete(:url_options) || {}
    url_opts = product_url_options product, url_opts
    url = params.merge url_opts
    link_to content_tag('span', product.name), url,
      opts.merge(target: '')
  end

  def link_to name = nil, options = nil, html_options = nil, &block
    html_options ||= {}
    options[:protocol] = '//' if options.is_a? Hash
    html_options[:target] ||= '_parent'
    super
  end

end
