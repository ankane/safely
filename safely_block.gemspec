require File.expand_path("../lib/version.rb", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "safely_block"
  spec.version       = Safely::VERSION
  spec.authors       = ["Andrew Kane"]
  spec.email         = ["andrew@chartkick.com"]
  spec.summary       = "Awesome exception handling"
  spec.description   = "Awesome exception handling"
  spec.homepage      = "https://github.com/ankane/safely"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "errbase"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", ">= 5"
end
