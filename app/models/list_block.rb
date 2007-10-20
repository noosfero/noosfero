class ListBlock < Design::Block

  def content

    lambda do
     content_tag(
              'ul',
              Person.find(:all).map do |p|
                content_tag(
                'li',
		link_to_homepage(content_tag('span', p.name), p.identifier)
                )
              end.join("\n"),
	      :class => 'people_list_block'
            )
    end

  end

end
