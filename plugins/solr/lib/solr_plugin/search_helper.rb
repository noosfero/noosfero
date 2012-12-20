class SolrPlugin < Noosfero::Plugin

  SortOptions = {
    :products => ActiveSupport::OrderedHash[ :none, {:label => _('Relevance')},
      :more_recent, {:label => _('More recent'), :solr_opts => {:sort => 'updated_at desc, score desc'}},
      :name, {:label => _('Name'), :solr_opts => {:sort => 'solr_plugin_name_sortable asc'}},
      :closest, {:label => _('Closest to me'), :if => proc{ logged_in? && (profile=current_user.person).lat && profile.lng },
        :solr_opts => {:sort => "geodist() asc",
          :latitude => proc{ current_user.person.lat }, :longitude => proc{ current_user.person.lng }}},
    ],
    :events => ActiveSupport::OrderedHash[ :none, {:label => _('Relevance')},
      :name, {:label => _('Name'), :solr_opts => {:sort => 'solr_plugin_name_sortable asc'}},
    ],
    :articles => ActiveSupport::OrderedHash[ :none, {:label => _('Relevance')},
      :name, {:label => _('Name'), :solr_opts => {:sort => 'solr_plugin_name_sortable asc'}},
      :more_recent, {:label => _('More recent'), :solr_opts => {:sort => 'updated_at desc, score desc'}},
    ],
    :enterprises => ActiveSupport::OrderedHash[ :none, {:label => _('Relevance')},
      :name, {:label => _('Name'), :solr_opts => {:sort => 'solr_plugin_name_sortable asc'}},
    ],
    :people => ActiveSupport::OrderedHash[ :none, {:label => _('Relevance')},
      :name, {:label => _('Name'), :solr_opts => {:sort => 'solr_plugin_name_sortable asc'}},
    ],
    :communities => ActiveSupport::OrderedHash[ :none, {:label => _('Relevance')},
      :name, {:label => _('Name'), :solr_opts => {:sort => 'solr_plugin_name_sortable asc'}},
    ],
  }

  module SearchHelper
    def asset_class(asset)
      asset.to_s.singularize.camelize.constantize
    end
  
    def asset_table(asset)
      asset_class(asset).table_name
    end

    def multiple_search?
      ['index', 'category_index'].include?(context.params[:action])
    end

    def filters(asset)
      case asset
      when :products
        ['solr_plugin_public:true']
      when :events
        []
      else
        ['solr_plugin_public:true']
      end
    end

    def results_only?
      context.params[:action] == 'index'
    end

    def solr_options(asset, category)
      asset_class = asset_class(asset)
      solr_options = {}
      if !multiple_search?
        if !results_only? and asset_class.respond_to? :facets
          solr_options.merge! asset_class.facets_find_options(context.params[:facet])
          solr_options[:all_facets] = true
        end
        solr_options[:filter_queries] ||= []
        solr_options[:filter_queries] += filters(asset)
        solr_options[:filter_queries] << "environment_id:#{context.environment.id}"
        solr_options[:filter_queries] << asset_class.facet_category_query.call(category) if category

        solr_options[:boost_functions] ||= []
        context.params[:order_by] = nil if context.params[:order_by] == 'none'
        if context.params[:order_by]
          order = SolrPlugin::SortOptions[asset][context.params[:order_by].to_sym]
          raise "Unknown order by" if order.nil?
          order[:solr_opts].each do |opt, value|
            solr_options[opt] = value.is_a?(Proc) ? instance_eval(&value) : value
          end
        end
      end
      solr_options
    end
  end
end
