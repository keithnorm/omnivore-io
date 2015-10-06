# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omnivore-io/api/version"

Gem::Specification.new do |s|
  s.name        = "omnivore-io"
  s.version     = OmnivoreIO::API::VERSION
  s.authors     = ["Zane Shannon"]
  s.email       = ["zcs@amvse.com"]
  s.homepage    = "http://github.com/amvse/omnivore-io"
  s.license     = 'MIT'
  s.summary     = %q{Ruby Client for the Omnivore.io API}
  s.description = %q{Ruby Client for the Omnivore.io API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rest_client'
end