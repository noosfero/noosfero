module ActionView
  module Helpers
    module FormTagHelper
      def form_tag_with_body_with_honeypot html_options = {}, content
        honeypot = html_options.delete 'honeypot'
        html = form_tag_with_body_without_honeypot html_options, content
        if honeypot
          captcha = honey_pot_captcha.html_safe
          html.insert html.index('</form>'), captcha
        end
        html
      end
      alias_method_chain :form_tag_with_body, :honeypot

    private

      def honey_pot_captcha
        html_ids = []
        honeypot_fields.collect do |f, l|
          html_ids << (html_id = "#{f}_hp_#{Time.now.to_i}")
          content_tag :div, :id => html_id do
            content_tag(:style, :type => 'text/css', :media => 'screen', :scoped => "scoped") do
              "#{html_ids.map { |i| "##{i}" }.join(', ')} { display:none; }"
            end +
            label_tag(f, l) +
            send([:text_field_tag, :text_area_tag][rand(2)], f)
          end
        end.join
      end
    end
  end
end
