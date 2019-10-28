require_relative "lib/safely/version"

Gem::Specification.new do |spec|
  spec.name          = "safely_block"
  spec.version       = Safely::VERSION
  spec.summary       = "Rescue and report exceptions in non-critical code"
  spec.homepage      = "https://github.com/ankane/safely"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency "errbase", ">= 0.1.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
