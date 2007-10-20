class EnterprisesBlock < Design::Block

  def content

      lambda do
     content_tag(
              'ul',
              Enterprise.find(:all).map do |p|
                content_tag(
                'li',
		link_to_homepage(content_tag('span', p.name, :class => 'people_list_block'), p.identifier)
                )
              end.join("\n")
            )
    end

  end

end
