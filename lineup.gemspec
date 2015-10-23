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

  gem.add_dependency('rspec', [">= 3.2.0"])
  gem.add_dependency('pxdoppelganger', [">= 0.1.1"])
  gem.add_dependency('selenium-webdriver', [">= 2.46.2"])
  gem.add_dependency('watir-webdriver', [">= 0.8.0"])
  gem.add_dependency('watir', [">= 5.0.0"])
  gem.add_dependency('headless', [">= 0.1.1"])
  gem.add_dependency('dimensions', [">= 1.3.0"])
  gem.add_dependency('chunky_png', [">= 1.3.4"])
  gem.add_dependency('oily_png', [">= 1.2.0"])

end
