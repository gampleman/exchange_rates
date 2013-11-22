# -*- encoding: utf-8 -*-
require File.expand_path('../lib/exchange_rates/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jakub Hampl"]
  gem.email         = ["honitom@seznam.cz"]
  gem.description   = %q{exchange_rates is a gem that allows currency conversion and rate history tracking.}
  gem.summary       = %q{Gives historical exchange rates}
  gem.homepage      = "https://github.com/gampleman/exchange_rates"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "exchange_rates"
  gem.require_paths = ["lib"]
  gem.version       = ExchangeRates::VERSION
  
  gem.add_dependency "nokogiri"
  gem.add_development_dependency "rspec"
end
