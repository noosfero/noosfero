require 'rubygems'
require 'nokogiri'
require 'open-uri'

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

class Html_parser
  def get_html(lattes_link = "")
    begin
      page = Nokogiri::HTML(open(lattes_link), nil, "UTF-8")
      page = page.css(".main-content").to_s()
      page = remove_class_tooltip(page)
      page = remove_img(page)
      page = remove_select(page)
      page = remove_footer(page)
      page = remove_further_informations(page)
		rescue OpenURI::HTTPError => e
      page = _("Lattes not found. Please, make sure the informed URL is correct.")
    rescue Timeout::Error => e
      page = _("Lattes Platform is unreachable. Please, try it later.")
    end
  end

  def remove_class_tooltip(page = "")
    while page.include? 'class="tooltip"' do
      page['class="tooltip"'] = 'class="link_not_to_mark"'
    end

    return page
  end

  def remove_img(page = "")
    fist_part_to_keep, *rest = page.split('<img')
    second_part = rest.join(" ")
    part_to_throw_away, *after_img = second_part.split('>',2)
    page = fist_part_to_keep + after_img.join(" ")
  end

  def remove_select(page = "")
    while page.include? '<label' do
      first_part_to_keep, *rest = page.split('<label')
      second_part = rest.join(" ")
      part_to_throw_away, *after_img = second_part.split('</select>')
      page = first_part_to_keep + after_img.join(" ")
    end

    return page
  end

  def remove_footer(page = "")
    first_part_to_keep, *rest = page.split('<div class="rodape-cv">')
    second_part = rest.join(" ")
    part_to_throw_away, *after_img = second_part.split('Imprimir Curr&iacute;culo</a>')
    page = first_part_to_keep + after_img.join(" ")
  end

  def remove_further_informations(page = "")
    first_part_to_keep, *rest = page.split('<a name="OutrasI')
    second_part = rest.join(" ")
    part_to_throw_away, *after_img = second_part.split('</div>',2)
    page = first_part_to_keep + after_img.join(" ")
  end
end
