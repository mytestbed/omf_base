# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omf_base/version"

Gem::Specification.new do |s|
  s.name        = "omf_base"
  s.version     = OMF::Base::VERSION
  s.authors     = ["NICTA"]
  s.email       = ["omf-user@lists.nicta.com.au"]
  s.homepage    = "https://www.mytestbed.net"
  s.summary     = %q{Some basic, but common functionality used in OMF libraries.}
  s.description = %q{Some basic, but common functionality used in OMF libraries.}

  s.rubyforge_project = "omf_base"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
#  s.add_development_dependency "minitest", "~> 2.11.3"
  s.add_runtime_dependency 'log4r'
end
