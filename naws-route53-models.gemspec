# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "naws-route53-models/version"

Gem::Specification.new do |s|
  s.name        = "naws-route53-models"
  s.version     = Naws::Route53::Models::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Matthew Boeh"]
  s.email       = ["matt@crowdcompass.com"]
  s.homepage    = ""
  s.summary     = %q{ActiveModel models for NAWS Route53 implementation}
  s.description = %q{ActiveModel models for NAWS Route53 implementation}

  s.rubyforge_project = "naws-route53-models"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
