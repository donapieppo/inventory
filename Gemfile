source "https://rubygems.org"
# git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "dm_unibo_user_search", git: "https://github.com/donapieppo/dm_unibo_user_search.git"
gem "dm_unibo_common", git: "https://github.com/donapieppo/dm_unibo_common.git", branch: "master"
# gem "dm_unibo_common", path: "/home/rails/gems/dm_unibo_common/"

gem "puma"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "sprockets-rails"

gem "lograge"

gem "net-ldap"
gem "ipaddr"
gem "redcarpet"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "omniauth"
gem "omniauth-rails_csrf_protection"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "ruby-lsp", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "pry-doc"
  gem "pry-byebug"
  gem "pry-rails"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

gem "image_processing", "~> 1.13"
