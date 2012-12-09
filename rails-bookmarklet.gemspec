$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails-bookmarklet/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-bookmarklet"
  s.version     = RailsBookmarklet::VERSION
  s.authors     = ["Dr. Oliver Friedmann"]
  s.email       = ["public@oliverfriedmann.de"]
  s.homepage    = "http://www.oliverfriedmann.de"
  s.summary     = "A bookmarklet gem for rails."
  s.description = "A bookmarklet gem for rails."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]

  s.require_paths = ["lib"]

  # s.add_dependency "rails", "~> 3.2.9"
# 
  # s.add_development_dependency "sqlite3"
end
