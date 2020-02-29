lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-asset-pipeline/version'

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-asset-pipeline'
  spec.version       = Jekyll::AssetPipeline::VERSION
  spec.authors       = ['Ample']
  spec.email         = ['sean@helloample.com']

  spec.summary       = 'External asset pipeline for Jekyll projects.'
  spec.homepage      = 'https://github.com/crdschurch/jekyll-asset-pipeline'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0.1'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'activesupport'
  spec.add_dependency 'jekyll', '~> 4.0.0'
end
