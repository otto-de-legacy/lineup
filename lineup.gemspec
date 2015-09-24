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
  gem.description = %q{lineup takes to screenshots of your app and compares them}
  gem.homepage = 'https://www.otto.de'
  gem.files = `git ls-files`.split($\)
end
