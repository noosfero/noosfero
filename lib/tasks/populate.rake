require File.dirname(__FILE__) + '/../../config/environment'
require 'noosfero'
require 'gettext/rails'
include GetText

DEFAULT_ENVIRONMENT_TEXT = <<EOF
<h1>Environment homepage</h1>
<p>
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec quis diam enim, et ultricies lacus. Pellentesque sit amet velit non ante bibendum consectetur. Etiam at aliquet mauris. Pellentesque volutpat pellentesque dolor, at cursus lacus suscipit varius. Nunc at lectus tortor, eu dapibus urna. Ut at odio sem, sed laoreet augue. Nunc vestibulum, lectus id tempor vulputate, turpis nisl placerat justo, non placerat est lectus a risus. Nullam elementum convallis lectus, eget volutpat sapien malesuada quis. Fusce aliquet elementum placerat. Donec dolor mauris, accumsan eu gravida sed, mollis a metus. Quisque dictum felis vel diam ornare dapibus. Cras vel est velit. Fusce in tincidunt urna. Proin tincidunt pellentesque turpis, nec blandit nulla volutpat at. Suspendisse potenti.
</p>
<p>
Nunc pellentesque sem in ante lacinia egestas nec et dolor. Fusce enim leo, condimentum nec iaculis in, convallis eget diam. Integer ultricies massa eu augue tristique eu semper lorem aliquam. Praesent nibh lorem, eleifend nec laoreet ac, tempus et augue. Phasellus pulvinar nibh eget magna pellentesque ultricies. Donec varius, sapien in fermentum pellentesque, odio risus viverra lectus, sed tincidunt arcu elit id ipsum. Nunc aliquet lobortis sem, vitae dapibus velit bibendum id. Vivamus nec augue arcu, sed adipiscing quam. Maecenas at porta odio. Ut felis arcu, commodo in vestibulum a, convallis et justo. Nulla feugiat odio in dui mollis a pretium orci porta. Morbi at nisl sem, non tempus dui.
</p>
<p>
Maecenas neque ante, bibendum sed mollis ac, aliquet eu dolor. Fusce quis enim mi, vestibulum laoreet purus. Curabitur vel odio non mi tempus commodo. Duis suscipit justo sit amet felis volutpat scelerisque. Integer in mi vulputate lacus porttitor posuere id sed sapien. Nam aliquam molestie est a eleifend. Integer at velit nec felis sodales ornare. Etiam magna elit, facilisis at consectetur nec, commodo sit amet sapien. Maecenas fermentum leo vitae turpis viverra auctor. Phasellus facilisis ipsum quis felis semper et condimentum augue porttitor. Morbi vitae mauris risus. Nunc lobortis quam eu tellus tempus ut tristique odio luctus. Fusce justo purus, tincidunt eu tristique et, pharetra non tortor. Cras malesuada accumsan venenatis. Donec ornare iaculis porttitor. Praesent vestibulum metus fermentum risus interdum gravida. Vivamus placerat commodo nunc vitae aliquet. Fusce sit amet libero facilisis ante dictum hendrerit ac sed massa. 
</p>
EOF

namespace :db do
  desc "Populate database with basic required data to run application"
  task :populate do
    Environment.create!(:name => 'Noosfero', :is_default => true, :description => DEFAULT_ENVIRONMENT_TEXT) unless (Environment.default)
  end
end

# vim: ft=ruby
