class EnterprisesBlock < Design::Block

  def content

    lambda do
      content_tag(:ul,
        Enterprise.find(:all).map do |p|
          content_tag(:li,
  	         content_tag(:span,
              link_to( p.name, :profile => p.identifier)
            )
          )
        end.join("\n"),
        :class => 'enterprises_list_block' 
      )
    end

  end

end
