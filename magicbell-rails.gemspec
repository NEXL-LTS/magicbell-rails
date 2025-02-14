Gem::Specification.new do |spec|
  spec.name        = 'magicbell-rails'
  spec.version     = '0.3.0'
  spec.authors     = ['Grant Petersen-Speelman', 'Connor Moot']
  spec.email       = ['grant@nexl.io', 'connor@nexl.io']
  spec.homepage    = 'https://github.com/NEXL-LTS/nexl360/local_gems/magicbell-rails'
  spec.summary     = 'Rails wrapper gem for magicbell'
  spec.description = 'Rails wrapper gem for magicbell'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'magicbell', '>= 2.2.1'
  spec.add_dependency 'rails', '>= 7.0.4'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
