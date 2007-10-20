class EnterprisesBlock < Design::Block

  def content

      lambda do
     content_tag(
              'ul',
              Enterprise.find(:all).map do |p|
                content_tag(
                'li',
		link_to_homepage(content_tag('span', p.name), p.identifier)
                )
              end.join("\n"), 
	      :class => 'enterprises_list_block'
            )
    end

  end

end
