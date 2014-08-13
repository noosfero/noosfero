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
		rescue
		    page = ""
		end 
	end

    def remove_class_tooltip(string = "")
        while string.include? 'class="tooltip"' do 
            string['class="tooltip"'] = 'class="link_not_to_mark"'
        end
        return string
   end

    def remove_img(string = "")
            fist_part_to_keep, *rest = string.split('<img')
            second_part = rest.join(" ")
            part_to_throw_away, *after_img = second_part.split('>',2)
            string = fist_part_to_keep + after_img.join(" ")
    end

    def remove_select(string = "")
        while string.include? '<label' do
            first_part_to_keep, *rest = string.split('<label')
            second_part = rest.join(" ")
            part_to_throw_away, *after_img = second_part.split('</select>')
            string = first_part_to_keep + after_img.join(" ")
        end
        return string
    end

    def remove_footer(string = "")
        first_part_to_keep, *rest = string.split('<div class="rodape-cv">')
        second_part = rest.join(" ")
        part_to_throw_away, *after_img = second_part.split('Imprimir Curr&iacute;culo</a>')
        string = first_part_to_keep + after_img.join(" ")
    end

    def remove_further_informations(string = "")
        first_part_to_keep, *rest = string.split('<a name="OutrasI')
        second_part = rest.join(" ")
        part_to_throw_away, *after_img = second_part.split('</div>',2)
        string = first_part_to_keep + after_img.join(" ")
    end
end
