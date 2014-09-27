# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby_bosh}
  s.version = "0.5.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pradeep Elankumaran"]
  s.date = %q{2009-04-21}
  s.description = %q{An XMPP BOSH session pre-initializer for Ruby web applications}
  s.email = %q{pradeep@intridea.com}
  s.files = ["VERSION.yml", "lib/ruby_bosh.rb", "spec/ruby_bosh_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/skyfallsin/ruby_bosh}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A BOSH session pre-initializer for Ruby web applications}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 0"])
      s.add_runtime_dependency(%q<adamwiggins-rest-client>, [">= 0"])
    else
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<adamwiggins-rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<adamwiggins-rest-client>, [">= 0"])
  end
end
