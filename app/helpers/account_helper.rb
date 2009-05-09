module AccountHelper

  include GetText

  def button_to_step(type, step, current_step, html_options = {})
    if current_step == step
      the_class = 'active'
      if html_options.has_key?(:class)
        html_options[:class] << " #{the_class}"
      else
        html_options[:class] = the_class
      end
    end
    if step == 1
      url = '#'
    else
      url = send('url_step_' + step.to_s)
    end
    button(type, step.to_s, url, html_options)
  end

  def button_to_step_without_text(type, step, html_options = {})
    url = 'url_step_' + step
    button_without_text(type, step, send(url), html_options)
  end

  def button_to_previous_step(step, html_options = {})
    step = step - 1
    if step > 1
      button_to_step_without_text(:left, step.to_s, html_options)
    end
  end

  def button_to_next_step(step, html_options = {})
    step = step + 1
    if step < 4
      button_to_step_without_text(:forward, step.to_s, html_options)
    end
  end

  def url_step_1
    options = {:controller => 'account', :action => 'signup', :wizard => true}
    Noosfero.url_options.merge(options)
  end

  def url_step_2
    options = {:controller => 'search', :action => 'assets', :asset => 'communities', :wizard => true}
    Noosfero.url_options.merge(options)
  end

  def url_step_3
    options = {:controller => 'friends', :action => 'invite', :profile => user.identifier, :wizard => true}
    Noosfero.url_options.merge(options)
  end

end
