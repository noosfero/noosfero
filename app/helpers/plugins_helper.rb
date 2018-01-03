module PluginsHelper

  def plugins_product_tabs
    @plugins.dispatch(:product_tabs, @product).map do |tab|
      {:title => tab[:title], :id => tab[:id], :content => instance_eval(&tab[:content])}
    end
  end

  def plugins_toolbar_actions_for_article(article)
    toolbar_actions = Array.wrap(@plugins.dispatch(:article_extra_toolbar_buttons, article))
    toolbar_actions.each do |action|
      [:title, :icon, :url].each { |param| raise "No #{param} was passed as parameter for #{action}" unless action.has_key?(param) }
    end
  end

  def plugins_toolbar(user)
    toolbar_actions = Array.wrap(@plugins.dispatch(:user_menu_items, user).collect { |content| instance_eval(&content) })
    toolbar_actions.each do |action|
      [:title, :icon, :url].each { |param| raise "No #{param} was passed as parameter for #{action}" unless action.has_key?(param) }
    end
  end

end
