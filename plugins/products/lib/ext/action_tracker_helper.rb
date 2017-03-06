require_dependency 'action_tracker_helper'

module ActionTrackerHelper

  def create_product_description ta
    _('created the product %{title}').html_safe % {
      title: link_to(truncate(ta.get_name), ta.get_url),
    }
  end

  def update_product_description ta
    _('updated the product %{title}').html_safe % {
      title: link_to(truncate(ta.get_name), ta.get_url),
    }
  end

  def remove_product_description ta
    _('removed the product %{title}').html_safe % {
      title: truncate(ta.get_name),
    }
  end

end
