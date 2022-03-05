source "https://rubygems.org"

Dir.glob("*.gemspec",base: File.expand_path("..",__FILE__)).each do |gemspec_path|
  gem_name = gemspec_path.scan(/^(.*)\.gemspec$/).flatten.first
  gemspec(:name => gem_name)
end

gem 'rake'
gem 'rspec'
gem 'yard'