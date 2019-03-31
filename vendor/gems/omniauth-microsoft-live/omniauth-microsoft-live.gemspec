# -*- encoding: utf-8 -*-
# stub: omniauth-microsoft-live 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "omniauth-microsoft-live"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Olefav"]
  s.date = "2019-03-30"
  s.email = ["ao@anahoret.com"]
  s.files = ["Gemfile", "Gemfile.lock", "README.md", "lib/omniauth-microsoft-live.rb", "lib/omniauth-microsoft-live/version.rb", "lib/omniauth/strategies/microsoft_live.rb", "omniauth-microsoft-live.gemspec", "spec/omniauth/strategies/microsoft_live_spec.rb", "spec/spec_helper.rb"]
  s.homepage = ""
  s.rubygems_version = "2.4.5.4"
  s.summary = "Windows Live hybrid signin strategy for OmniAuth"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<omniauth-oauth2>, ["~> 1.0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.0.3"])
      s.add_development_dependency(%q<rspec>, ["~> 2.7"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
    else
      s.add_dependency(%q<omniauth-oauth2>, ["~> 1.0"])
      s.add_dependency(%q<multi_json>, [">= 1.0.3"])
      s.add_dependency(%q<rspec>, ["~> 2.7"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
    end
  else
    s.add_dependency(%q<omniauth-oauth2>, ["~> 1.0"])
    s.add_dependency(%q<multi_json>, [">= 1.0.3"])
    s.add_dependency(%q<rspec>, ["~> 2.7"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
  end
end
