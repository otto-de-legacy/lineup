require File.expand_path('../lib/lineup/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = %w(Finn Lorbeer)
  gem.version = Lineup::Version
  gem.name = 'lineup'
  gem.platform = Gem::Platform::RUBY
  gem.require_paths = %w(lib)
  gem.license = 'MIT'
  gem.email = %w(finn.von.friesland@googlemail.com)
  gem.summary = "lineup will help you in your automated design regression testing"
  gem.description = %q{lineup takes to screenshots of your app and compares them to references in order to find design flaws in your new code.}
  gem.homepage = 'https://www.otto.de'
  gem.files = `git ls-files`.split("\n")

  gem.add_dependency('rspec')
  gem.add_dependency('pxdoppelganger', ['0.1.1'])
  gem.add_dependency('selenium-webdriver')
  gem.add_dependency('watir-webdriver')
  gem.add_dependency('watir')
  gem.add_dependency('headless')
  gem.add_dependency('dimensions')
  gem.add_dependency('chunky_png')
  gem.add_dependency('oily_png')

end
