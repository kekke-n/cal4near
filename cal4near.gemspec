# frozen_string_literal: true

require_relative "lib/cal4near/version"

Gem::Specification.new do |spec|
  spec.name          = "cal4near"
  spec.version       = Cal4near::VERSION
  spec.authors       = ["nakamaksk"]
  spec.email         = ["adebayanen@gmail.com"]

  spec.summary       = "Fetch calendar information."
  spec.description   = "Fetch calendar information."
  spec.homepage      = "https://github.com/nakamaksk/cal4near"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nakamaksk/cal4near"
  spec.metadata["changelog_uri"] = "https://github.com/nakamaksk/cal4near"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'google-api-client'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'byebug'

end
