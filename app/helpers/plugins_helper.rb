module PluginsHelper

  def plugins_product_tabs
    @plugins.dispatch(:product_tabs, @product).map do |tab|
      {:title => tab[:title], :id => tab[:id], :content => instance_eval(&tab[:content])}
    end
  end

end
